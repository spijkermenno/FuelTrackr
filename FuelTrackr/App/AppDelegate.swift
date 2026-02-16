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

@MainActor
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private let apnsDefaultsKey = "fueltrackr_lastKnownAPNsToken"
    private let pendingEventsKey = "fueltrackr_pendingNotificationEvents"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
#if !DEBUG
        Task {
            await configureScovilleAndRegisterDevice()
        }
#endif
        
        // Firebase
        if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
            FirebaseApp.configure()
        }
        
        // Notifications - delegate setup only, permission will be requested during onboarding
        setUpNotifications(application)
        
        return true
    }
    
    // MARK: Scoville
    func configureScovilleAndRegisterDevice() async {
        await ScovilleEnvironment.configureFromDefaults()

        let cachedToken = UserDefaults.standard.string(forKey: apnsDefaultsKey) ?? ""

        Scoville.registerDevice(token: cachedToken) { [weak self] result in
            switch result {
            case .success:
                Task { @MainActor in
                    Scoville.track(StandardEvent.appOpened)
                    
                    // Flush any pending notification events NOW that Scoville is ready
                    self?.flushPendingNotificationEvents()
                }

            case .failure(let error):
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
            return
        }
        
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
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Foreground delivery (NOT a tap) - called when notification fires while app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Check application state synchronously on main thread
        let options: UNNotificationPresentationOptions
        if Thread.isMainThread {
            let state = UIApplication.shared.applicationState
            print("[Notifications] 📬 Notification received in foreground - state: \(state.rawValue)")
            options = state == .active ? [.banner, .sound] : []
        } else {
            // If not on main thread, dispatch synchronously to check state
            var state: UIApplication.State = .background
            DispatchQueue.main.sync {
                state = UIApplication.shared.applicationState
                print("[Notifications] 📬 Notification received in foreground - state: \(state.rawValue)")
            }
            options = state == .active ? [.banner, .sound] : []
        }
        
        // Call completion handler synchronously
        completionHandler(options)
    }
    
    /// Background or Inactive → TAP - called when user taps on a notification
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Extract all needed values from response before capturing in closure (fixes Sendable warning)
        let urlString = response.notification.request.content.userInfo["url"] as? String
        let notificationId = response.notification.request.content.userInfo["notification_id"]
        
        // Convert userInfo to a Sendable-safe format
        let userInfoDict = response.notification.request.content.userInfo.reduce(into: [String: String]()) { result, pair in
            result[String(describing: pair.key)] = String(describing: pair.value)
        }
        
        // Extract notification ID as Int if available
        let notificationIdInt = (notificationId as? Int) ?? ((notificationId as? String).flatMap(Int.init))
        
        // Call completion handler synchronously first (required by API)
        completionHandler()
        
        // Handle tracking and UI updates asynchronously on main actor
        Task { @MainActor [weak self] in
            print("[Notifications] 👆 Notification tapped by user")
            
            // Handle monthly recap notification
            if let urlString = urlString,
               urlString == "fueltrackr://monthlyRecap" {
                // Post notification to show monthly recap sheet
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "ShowMonthlyRecap"),
                    object: nil
                )
            }
            
            // Track notification opened using ScovilleKit API
            // Note: We need to call this on main actor, but response is not Sendable
            // So we use trackNotificationOpened with ID if available, otherwise queue
            if let notificationId = notificationIdInt {
                // Use trackNotificationOpened with notification ID (Sendable-safe)
                self?.trackWithNotificationId(notificationId, userInfo: userInfoDict)
            } else {
                // No notification ID available, queue the event for later processing
                print("[Notifications] ⚠️ No notification ID found, queuing event")
                self?.handleNotificationTap(userInfoDict)
            }
        }
    }
    
    /// Helper method to track notification with ID (Sendable-safe)
    @MainActor
    private func trackWithNotificationId(_ notificationId: Int, userInfo: [String: String]) {
        Scoville.trackNotificationOpened(notificationId: notificationId) { [weak self] result in
            switch result {
            case .success(let trackingResponse):
                print("[Notifications] ✅ Notification opened tracked: ID \(trackingResponse.data.id)")
            case .failure(let error):
                print("[Notifications] ❌ Failed to track notification opened: \(error.localizedDescription)")
                // Final fallback: queue the event
                Task { @MainActor in
                    self?.handleNotificationTap(userInfo)
                }
            }
        }
    }
    
    // MARK: - Notification Event Queue Management
    
    private struct PendingNotificationEvent: Codable {
        let notificationId: String?
        let payload: [String: String]
        let timestamp: Date
    }
    
    private func queueNotificationEvent(_ event: PendingNotificationEvent) {
        var queue = loadPendingEvents()
        queue.append(event)
        
        if let data = try? JSONEncoder().encode(queue) {
            UserDefaults.standard.set(data, forKey: pendingEventsKey)
            print("[Notifications] 💾 Queued notification event for later processing")
        }
    }
    
    private func loadPendingEvents() -> [PendingNotificationEvent] {
        guard let data = UserDefaults.standard.data(forKey: pendingEventsKey),
              let events = try? JSONDecoder().decode([PendingNotificationEvent].self, from: data) else {
            return []
        }
        return events
    }
    
    func flushPendingNotificationEvents() {
        let events = loadPendingEvents()
        guard !events.isEmpty else {
            return
        }
        
        print("[Notifications] 🔄 Flushing \(events.count) pending notification event(s)")
        
        for event in events {
            if let notificationIdString = event.notificationId, let notificationId = Int(notificationIdString) {
                // Use ScovilleKit API for notification opened tracking
                Scoville.trackNotificationOpened(notificationId: notificationId) { result in
                    switch result {
                    case .success(let response):
                        print("[Notifications] ✅ Queued notification opened tracked: ID \(response.data.id)")
                    case .failure(let error):
                        print("[Notifications] ❌ Failed to track queued notification opened: \(error.localizedDescription)")
                    }
                }
            } else {
                // Fallback: track as generic notification tapped event if no notification ID
                Task { @MainActor in
                    // You can add a custom event here if needed, or just log it
                    print("[Notifications] ⚠️ No notification ID found in queued event, skipping tracking")
                }
            }
        }
        
        // Clear queue after processing
        UserDefaults.standard.removeObject(forKey: pendingEventsKey)
        print("[Notifications] ✅ Cleared notification event queue")
    }
    
    // MARK: - Notification Tap Handler
    
    /// Fallback handler for queuing notification events when ScovilleKit API is not available
    private func handleNotificationTap(_ userInfo: [String: String]) {
        let id = userInfo["notification_id"]
        let notificationId = id
        
        // Queue the event for later processing
        let event = PendingNotificationEvent(
            notificationId: notificationId,
            payload: userInfo,
            timestamp: Date()
        )
        queueNotificationEvent(event)
    }
}
