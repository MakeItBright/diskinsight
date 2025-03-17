//
//  FormattedDiskInfo.swift
//  diskinsight
//
//  Created by Juri Breslauer on 3/15/25.
//
import Foundation

/// Model representing disk usage information
struct FormattedDiskInfo: Identifiable {
    
    let id = UUID() // Unique identifier for SwiftUI List
    let title: String // Name of the disk section (e.g., "System", "Available", "User Data")
    let size: Int64 // Used space in bytes
    let totalSize: Int64 // Total space in bytes
    
    /// Formats the used space as a human-readable string (e.g., "11 MB")
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    /// Formats the total space as a human-readable string (e.g., "910 MB")
    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    /// Calculates the usage percentage (normalized between 0.0 and 1.0)
    var percentage: Double {
        guard totalSize > 0 else { return 0.0 }
        return min(1.0, max(0.0, Double(size) / Double(totalSize)))
    }
    
    /// Example instance for testing and previews
    static var example: FormattedDiskInfo {
        FormattedDiskInfo(
            title: "System",
            size: 11 * 1024 * 1024,  // 11 MB in bytes
            totalSize: 910 * 1024 * 1024  // 910 MB in bytes
        )
    }
    
    /// Sample dataset for SwiftUI previews
    static var examples: [FormattedDiskInfo] {
        [
            FormattedDiskInfo(title: "System",
                              size: 11 * 1024 * 1024,
                              totalSize: 910 * 1024 * 1024),
            FormattedDiskInfo(title: "Available",
                              size: 300 * 1024 * 1024,
                              totalSize: 910 * 1024 * 1024),
            FormattedDiskInfo(title: "User Data",
                              size: 600 * 1024 * 1024,
                              totalSize: 910 * 1024 * 1024)
        ]
    }
}
