//
//  DiskInfo.swift
//  diskinsight
//
//  Created by Yuri Breslavets on 3/17/25.
//

import Foundation

/// Represents disk information, including size, usage, and mount point.
struct DiskInfo {
    
    let fileSystemName: String // Name of the file system (e.g., "APFS")
    let size: Int64 // Total disk size in bytes
    let used: Int64 // Used disk space in bytes
    let available: Int64 // Available disk space in bytes
    let capacity: Int // Used capacity in percentage (e.g., 75%)
    let mountPoint: String // Mount point of the disk (e.g., "/")
    
    /// Checks if the disk is the system volume (root partition "/")
    var isSystemVolume: Bool {
        mountPoint == "/"
    }
    
    /// Checks if the disk is the data volume (user data partition "/System/Volumes/Data")
    var isDataVolume: Bool {
        mountPoint == "/System/Volumes/Data"
    }
}


extension Array where Element == DiskInfo {
    
    /// Finds and returns the system volume from the disk list
    var systemVolume: DiskInfo? {
        first { $0.isSystemVolume }
    }

    /// Finds and returns the data volume from the disk list
    var dataVolume: DiskInfo? {
        first { $0.isDataVolume }
    }
}
