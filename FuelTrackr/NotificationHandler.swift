//
//  NotificationHandler.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 10/04/2025.
//


import SwiftUI
import UserNotifications

class NotificationHandler: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var shouldShowMonthlyRecapSheet = false

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // This method gets called when a notification is tapped (or delivered in the foreground).
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let urlString = response.notification.request.content.userInfo["url"] as? String,
           urlString == "fueltrackr://monthlyRecap" {
            DispatchQueue.main.async {
                self.shouldShowMonthlyRecapSheet = true
            }
        }
        completionHandler()
    }
}