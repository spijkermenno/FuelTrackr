//
//  FuelTrackrApp.swift
//  FuelTrackr
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics

import Domain
import Data

@main
struct FuelTrackrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var notificationHandler = NotificationHandler()

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
                //.environmentObject(notificationHandler)
//                .onOpenURL { url in
//                    if url.absoluteString == "fueltrackr://monthlyRecap" {
//                        notificationHandler.shouldShowMonthlyRecapSheet = true
//                    }
//                }
        }
    }
}
