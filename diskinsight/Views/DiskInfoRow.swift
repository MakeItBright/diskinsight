//
//  DiskInfoRow.swift
//  diskinsight
//
//  Created by Yuri Breslavets on 3/17/25.
//

import SwiftUI

struct DiskInfoRow: View {
    
    let info: FormattedDiskInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Title and Size
            HStack {
                Text(info.title)
                    .font(.headline)
                
                Spacer()
                
                Text(info.formattedSize)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    // Background bar
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    // Filled progress bar
                    Capsule()
                        .fill(progressColor)
                        .frame(width: max(5, proxy.size.width * info.percentage), height: 6)
                        .animation(.easeInOut(duration: 0.5), value: info.percentage)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 5)
    }
    
    /// Determines progress bar color based on disk section
    var progressColor: Color {
        switch info.title {
            case "System": return .blue
            case "Available": return .green
            default: return .orange
        }
    }
}

#Preview {
    DiskInfoRow(info: .example)
        .padding()
        .frame(width: 300)
}
