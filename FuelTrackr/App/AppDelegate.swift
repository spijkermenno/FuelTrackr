//
//  AppDelegate.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import ScovilleKit
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private let apnsDefaultsKey = "fueltrackr_lastKnownAPNsToken"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
#if !DEBUG
        Task {
            await configureScovilleAndRegisterDevice()
        }
#else
        print("[Scoville] skipping registering device because we're in DEBUG mode")
#endif
        
        // Firebase
        if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
            FirebaseApp.configure()
        }
        
        // Notifications - delegate setup only, permission will be requested during onboarding
        setUpNotifications(application)
        
        print("🚀 FuelTrackr launched with Firebase + Scoville")
        return true
    }
    
    // MARK: Scoville
    func configureScovilleAndRegisterDevice() async {
        await ScovilleEnvironment.configureFromDefaults()

        let cachedToken = UserDefaults.standard.string(forKey: apnsDefaultsKey) ?? ""
        print("[Scoville] 🧩 Registering device after full configuration (token: \(cachedToken.isEmpty ? "none" : "exists"))")

        Scoville.registerDevice(token: cachedToken) { result in
            switch result {
            case .success:
                print("✅ [Scoville] Device registration success")

                Task { @MainActor in
                    Scoville.track(StandardEvent.appOpened)
                }

            case .failure(let error):
                print("❌ [Scoville] Device registration failed: \(error.localizedDescription)")
                Crashlytics.crashlytics().record(error: error)
            }
        }
    }
    
    // MARK: APNs callback
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let cached = UserDefaults.standard.string(forKey: apnsDefaultsKey)
        
        registerWithScovilleIfChanged(newToken: tokenString, cached: cached)
    }
    
    private func registerWithScovilleIfChanged(newToken: String, cached: String?) {
        guard newToken != cached else {
            print("[token] same APNs token, skipping Scoville update")
            return
        }
        
        print("[token] new APNs token, sending to Scoville")
        Scoville.registerDevice(token: newToken)
        UserDefaults.standard.set(newToken, forKey: apnsDefaultsKey)
    }
    
    // MARK: Notifications
    private func setUpNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        // Note: Permission request moved to onboarding flow
        // Only register for remote notifications if already authorized (for returning users)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
}
