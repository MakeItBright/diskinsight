//
//  ContentView.swift
//  diskinsight
//
//  Created by Juri Breslauer on 3/13/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DiskInfoFetcher() // ViewModel for fetching disk info

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // App Title
            Text("Disk Usage Overview")
                .font(.title2)
                .bold()
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Display Total Disk Space
            if let totalDiskSize = viewModel.totalDiskSpace {
                Text("Your total disk space: \(totalDiskSize)")
                    .font(.headline)
                    .foregroundColor(Color.gray)
                    .padding(.bottom, 5)
            }
            // List of Disk Info
            if viewModel.isLoading {
                VStack {
                        Spacer() // Pushes content down
                        ProgressView("Analyzing disk space...")
                            .padding()
                            .scaleEffect(1.2) // Slightly larger for visibility
                        Spacer() // Pushes content up
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Expands to center
            } else if let error = viewModel.error {
                // Error Message
                Text("❌ Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else {
               

                List(viewModel.diskInfos) { info in
                    DiskInfoRow(info: info)
                        .padding(.vertical, 5)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
//                .scrollContentBackground(.hidden)
                .frame(height: 160) // Limit height to prevent overflow
            }
           
            // Refresh Button
            HStack {
                Spacer()
                Button(action: {
                    viewModel.loadDiskInfo()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .padding(.bottom)
        }
        .padding()
        .onAppear {
            viewModel.loadDiskInfo()
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 350, height: 300)
}
