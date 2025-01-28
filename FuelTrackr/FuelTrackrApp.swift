//
//  FuelTrackrApp.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

@main
struct FuelTrackrApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Vehicle.self, FuelUsage.self, Maintenance.self]) // Attach persistent container
        }
    }
}
