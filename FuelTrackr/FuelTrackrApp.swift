//
//  FuelTrackrApp.swift
//  FuelTrackr
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics

@main
struct FuelTrackrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var notificationHandler = NotificationHandler()

    private let container: ModelContainer

    init() {
        // Initialize Firebase Analytics
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [
            AnalyticsParameterItemID: UUID().uuidString,
        ])

        // Initialize SwiftData ModelContainer manually
        do {
            container = try ModelContainer(for: Vehicle.self, FuelUsage.self, Maintenance.self, Mileage.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(context: container.mainContext)
                .modelContainer(container) // inject the ModelContainer into the environment
                .environmentObject(notificationHandler) // keep your notification handler!
                .onOpenURL { url in
                    if url.absoluteString == "fueltrackr://monthlyRecap" {
                        notificationHandler.shouldShowMonthlyRecapSheet = true
                    }
                }
        }
    }
}
