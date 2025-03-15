//
//  StorageFetcher.swift
//  diskinsight
//
//  Created by Juri Breslauer on 3/15/25.
//

import Foundation


class DiskInfoFetcher: ObservableObject {

    enum CommandError: Error {
        case commandFailed(String)
        case parsingFailed
        case invalidData
        case emptyOutput
    }

    @Published private(set) var diskInfos = [FormattedDiskInfo]()
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    @MainActor
    func loadDiskInfo()  {
        isLoading = true

        Task {
            do {
                diskInfos = try await getDiskInfo()
                isLoading = false
            } catch {
                self.error = error
                isLoading = false
            }
        }
    }

    /// Выполняет команду терминала и получает результат
    private func runShellCommand(_ command: String) async throws -> String {
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe
        process.arguments = ["-c", command]
        process.launchPath = "/bin/zsh"  // Используем zsh (можно заменить на /bin/bash)

        process.launch()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8), !output.isEmpty else {
            throw CommandError.emptyOutput
        }

        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Получает информацию о диске через команду `df -h`
    private func getDiskInfo() async throws -> [FormattedDiskInfo] {
        let output = try await runShellCommand("df -h")
        return try parseDiskInfo(output)
    }

    /// Парсит результат команды `df -h`
    private func parseDiskInfo(_ output: String) throws -> [FormattedDiskInfo] {
        var diskInfos = [FormattedDiskInfo]()
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }

        guard lines.count > 1 else { throw CommandError.parsingFailed }

        for line in lines.dropFirst() {  // Пропускаем заголовок
            let components = line.split(separator: " ", omittingEmptySubsequences: true)

            guard components.count >= 6 else { continue } // Проверяем, есть ли достаточное количество данных

            let name = String(components[0])
            let totalSize = String(components[1])
            let usedSize = String(components[2])
            let availableSize = String(components[3])
            let usagePercentage = String(components[4])

            let diskInfo = FormattedDiskInfo(
                name: name,
                totalSize: totalSize,
                usedSize: usedSize,
                availableSize: availableSize,
                usagePercentage: usagePercentage
            )

            diskInfos.append(diskInfo)
        }

        if diskInfos.isEmpty {
            throw CommandError.emptyOutput
        }

        return diskInfos
    }
}
