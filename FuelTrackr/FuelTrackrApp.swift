//
//  FuelTrackrApp.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct FuelTrackrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
            Analytics.logEvent(AnalyticsEventAppOpen, parameters: [
                AnalyticsParameterItemID: UUID().uuidString,
            ])
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Vehicle.self, FuelUsage.self, Maintenance.self, Mileage.self])
        }
    }
}
