//
//  diskinsightApp.swift
//  diskinsight
//
//  Created by Juri Breslauer on 3/13/25.
//

import SwiftUI

@main
struct diskinsightApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .frame(width: 350)
        } label: {
            Label("DiskInsight", systemImage: "externaldrive.connected.to.line.below.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
