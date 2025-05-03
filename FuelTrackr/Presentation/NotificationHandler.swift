// MARK: - Package: Presentation

//
//  NotificationHandler.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/04/2025.
//

import SwiftUI
import Domain
import UserNotifications

public final class NotificationHandler: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published public var shouldShowMonthlyRecapSheet = false

    public override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let urlString = response.notification.request.content.userInfo["url"] as? String,
           urlString == "fueltrackr://monthlyRecap" {
            // Future behavior: open MonthlyRecapSheet
            shouldShowMonthlyRecapSheet = true
        }

        completionHandler()
    }
}
