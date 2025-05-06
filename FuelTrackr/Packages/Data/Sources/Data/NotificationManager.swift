// MARK: - Package: Data
//
//  NotificationManager.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import UserNotifications
import Domain


public final class NotificationManager: NotificationManagerProtocol {
    private let center = UNUserNotificationCenter.current()
    private let settingsRepository: SettingsRepositoryProtocol

    public init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
    }
    
    // MARK: - Authorization

    public func requestAuthorization(completion: @escaping @Sendable (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Monthly Recap Notifications

    public func scheduleMonthlyRecapNotification(for date: Date) {
        cancelMonthlyRecapNotification()

        guard settingsRepository.isNotificationsEnabled() else {
            cancelAllNotifications()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("monthly_recap_notification_title", comment: "")
        content.body = NSLocalizedString("monthly_recap_notification_body", comment: "")
        content.sound = .default
        content.userInfo = ["url": "fueltrackr://monthlyRecap"]

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(
            identifier: "MonthlyRecapNotification",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling monthly recap notification: \(error.localizedDescription)")
            } else {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateStyle = .full
                formatter.timeStyle = .short
                print("Monthly recap notification scheduled for \(formatter.string(from: date))")
            }
        }
    }

    public func cancelMonthlyRecapNotification() {
        center.removePendingNotificationRequests(withIdentifiers: ["MonthlyRecapNotification"])
    }

    // MARK: - Test Notifications

    public func scheduleTestNotification() {
        guard settingsRepository.isNotificationsEnabled() else {
            cancelAllNotifications()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("test_notification_title", comment: "")
        content.body = NSLocalizedString("test_notification_body", comment: "")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

        let request = UNNotificationRequest(
            identifier: "TestNotification",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled to fire in 1 minute.")
            }
        }
    }

    // MARK: - Custom Notifications

    public func scheduleNotification(title: String, body: String, inDays: Int, atHour: Int, atMinute: Int) {
        guard settingsRepository.isNotificationsEnabled() else {
            cancelAllNotifications()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let calendar = Calendar.current
        guard let triggerDate = calendar.date(byAdding: .day, value: inDays, to: Date()) else { return }

        var components = calendar.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = atHour
        components.minute = atMinute
        components.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(components)")
            }
        }
    }

    // MARK: - Cancel All

    public func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
