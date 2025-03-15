//
//  FormattedDiskInfo.swift
//  diskinsight
//
//  Created by Juri Breslauer on 3/15/25.
//
import Foundation

struct FormattedDiskInfo: Identifiable {
    let id = UUID()
    let name: String
    let totalSize: String
    let usedSize: String
    let availableSize: String
    let usagePercentage: String
}
