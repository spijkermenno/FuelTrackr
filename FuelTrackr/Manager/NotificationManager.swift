//
//  NotificationManager.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 31/01/2025.
//

import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    private let settingsRepository = SettingsRepository()

    /// Schedule a notification in `days` from now at a specific time (`hour`:`minute`)
    func scheduleNotification(title: String, body: String, inDays: Int, atHour: Int, atMinute: Int) {
        // Check if notifications are enabled in user settings
        guard settingsRepository.isNotificationsEnabled() else {
            print("Notifications are disabled in user settings. Skipping scheduling.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let calendar = Calendar.current
        let now = Date()
        
        var targetDate = calendar.date(byAdding: .day, value: inDays, to: now)!
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
        dateComponents.hour = atHour
        dateComponents.minute = atMinute

        targetDate = calendar.date(from: dateComponents)!

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(targetDate)")
            }
        }
    }

    /// Cancel all scheduled notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
