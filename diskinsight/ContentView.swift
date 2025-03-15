//
//  ContentView.swift
//  diskinsight
//
//  Created by Juri Breslauer on 3/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DiskInfoFetcher()

    var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("DiskInsight")
                    .font(.title2)
                    .bold()
                
            }
            List(viewModel.diskInfos) { disk in
                        VStack(alignment: .leading) {
                            Text("📂 \(disk.name)").font(.headline)
                            Text("Общий размер: \(disk.totalSize)")
                            Text("Использовано: \(disk.usedSize) (\(disk.usagePercentage))")
                            Text("Свободно: \(disk.availableSize)").foregroundColor(.green)
                        }
                        .padding()
                    }
                    .navigationTitle("Анализ Диска")
                    .toolbar {
                        Button("🔄 Обновить") {
                            viewModel.loadDiskInfo()
                        }
                    }
                    .onAppear {
                        viewModel.loadDiskInfo()
                    }
        
    }
}

#Preview {
    ContentView()
        .frame(width: 300)
}
