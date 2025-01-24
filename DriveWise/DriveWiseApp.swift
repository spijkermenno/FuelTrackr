//
//  DriveWiseApp.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

@main
struct DriveWiseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Vehicle.self, HistoryItem.self]) // Attach persistent container
        }
    }
}
