import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    private let settings = SettingsRepository()
    
    private init() {}

    /// Request notification authorization from the user.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Schedules a monthly recap notification for the given date.
    /// Checks if notifications are enabled locally; if disabled, cancels pending notifications.
    func scheduleMonthlyRecapNotification(for date: Date) {
        // First, cancel any existing monthly recap notification so we don't schedule duplicates.
        cancelMonthlyRecapNotification()
        
        // Check if notifications are enabled.
        guard settings.isNotificationsEnabled() else {
            cancelAllNotifications()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("monthly_recap_notification_title", comment: "Title for monthly recap notification")
        content.body = NSLocalizedString("monthly_recap_notification_body", comment: "Body for monthly recap notification")
        content.sound = .default
        content.userInfo = ["url": "fueltrackr://monthlyRecap"]
        
        // Create a date trigger.
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Use a fixed identifier.
        let identifier = "MonthlyRecapNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
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
    
    func cancelMonthlyRecapNotification() {
        center.removePendingNotificationRequests(withIdentifiers: ["MonthlyRecapNotification"])
    }
    
    /// Schedules a test notification to be delivered in one minute.
    func scheduleTestNotification() {
        guard settings.isNotificationsEnabled() else {
            cancelAllNotifications()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("test_notification_title", comment: "Title for test notification")
        content.body = NSLocalizedString("test_notification_body", comment: "Body for test notification")
        content.sound = UNNotificationSound.default
        
        // Create a trigger to fire in 1 minute.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        
        let identifier = "TestNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled to fire in 1 minute.")
            }
        }
    }
    
    /// Cancel all scheduled notifications.
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    func scheduleNotification(title: String, body: String, inDays: Int, atHour: Int, atMinute: Int) {
        guard settings.isNotificationsEnabled() else {
            cancelAllNotifications()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        // First, add the number of days to today.
        guard let triggerDate = calendar.date(byAdding: .day, value: inDays, to: Date()) else { return }
        
        // Then, set the desired hour and minute on that date.
        var components = calendar.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = atHour
        components.minute = atMinute
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(components)")
            }
        }
    }
}
