//
//  DiskInfoFetcher.swift
//  diskinsight
//
//  Created by Juri Breslauer on 3/15/25.
//

import Foundation

/// ViewModel responsible for fetching and parsing disk usage information
class DiskInfoFetcher: ObservableObject {
    
    /// Enum representing potential errors that may occur while executing shell commands
    enum CommandError: Error {
        case commandFailed(String) // Command execution failed
        case parsingFailed // Failed to parse output
        case invalidData // Data format is incorrect
        case emptyOutput // No output received from command
    }

    @Published private(set) var diskInfos: [FormattedDiskInfo] = [] // Holds parsed disk info
    @Published private(set) var isLoading: Bool = false // Indicates whether data is being fetched
    @Published private(set) var error: Error? // Stores any encountered error
                        
    @Published private(set) var totalDiskSpace: String? /// Store total disk space as a published property

    /// Loads disk information asynchronously
    @MainActor
    func loadDiskInfo() {
        isLoading = true // Start loading indicator
        
        Task {
            do {
                let fetchedDiskInfos = try await getDiskInfo()
                DispatchQueue.main.async {
                    self.diskInfos = fetchedDiskInfos
                    self.totalDiskSpace = fetchedDiskInfos.first?.formattedTotalSize
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error // Store error if occurs
                    self.isLoading = false
                }
            }
        }
    }

    /// Executes a shell command and returns the output as a string
    private func runShellCommand(_ command: String) async throws -> String {
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe
        process.arguments = ["-c", command]
        process.launchPath = "/bin/zsh" // Using zsh (can be replaced with /bin/bash)

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8), !output.isEmpty else {
            throw CommandError.emptyOutput
        }

        guard process.terminationStatus == 0 else {
            throw CommandError.commandFailed(output)
        }

        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Retrieves disk usage details using the `df -k -P` command
    private func getDiskInfo() async throws -> [FormattedDiskInfo] {
        let output = try await runShellCommand("df -k -P")
        let parsedDiskInfos = try parse(output)
        return parseFormatted(parsedDiskInfos)
    }

    /// Parses raw output from `df -k -P` and converts it into an array of `DiskInfo`
    private func parse(_ output: String) throws -> [DiskInfo] {
        let lines = output.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        guard lines.count > 1 else { throw CommandError.emptyOutput } // Ensure output is valid

        // Skip header line
        let dataLines = lines.dropFirst()

        return dataLines.compactMap { line -> DiskInfo? in
            let components = line.split(separator: " ", omittingEmptySubsequences: true)
            guard components.count >= 6 else { return nil }

            return DiskInfo(
                fileSystemName: String(components[0]),
                size: Int64(components[1]) ?? 0,      // Now directly in KB
                used: Int64(components[2]) ?? 0,
                available: Int64(components[3]) ?? 0,
                capacity: Int(components[4].replacingOccurrences(of: "%", with: "")) ?? 0,
                mountPoint: components[5...].joined(separator: " ")
            )
        }
    }

    /// Converts `DiskInfo` into `FormattedDiskInfo` for UI display
    private func parseFormatted(_ infos: [DiskInfo]) -> [FormattedDiskInfo] {
        var results = [FormattedDiskInfo]()

        let total = infos.systemVolume?.size ?? 0

        if let systemVolume = infos.systemVolume {
            results.append(
                FormattedDiskInfo(
                    title: "System",
                    size: systemVolume.used * 1024, // Convert from KB to Bytes
                    totalSize: total * 1024
                )
            )
        }

        if let dataVolume = infos.dataVolume {
            results.append(
                FormattedDiskInfo(
                    title: "Available",
                    size: dataVolume.available * 1024, // Convert from KB to Bytes
                    totalSize: total * 1024
                )
            )

            results.append(
                FormattedDiskInfo(
                    title: "User Data",
                    size: dataVolume.used * 1024, // Convert from KB to Bytes
                    totalSize: total * 1024
                )
            )
        }

        return results
    }
}
