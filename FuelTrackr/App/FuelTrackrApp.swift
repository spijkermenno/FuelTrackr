//
//  FuelTrackrApp.swift
//  FuelTrackr
//

import SwiftUI
import SwiftData
import FirebaseCore

import Domain
import Data

@main
struct FuelTrackrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Vehicle.self, FuelUsage.self, Maintenance.self, Mileage.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
