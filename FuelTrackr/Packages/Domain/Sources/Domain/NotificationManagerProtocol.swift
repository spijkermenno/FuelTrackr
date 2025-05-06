//
//  NotificationManagerProtocol.swift
//  Domain
//
//  Created by Menno Spijker on 30/04/2025.
//


import Foundation

public protocol NotificationManagerProtocol {
    func requestAuthorization(completion: @escaping @Sendable (Bool) -> Void)
    func scheduleMonthlyRecapNotification(for date: Date)
    func scheduleTestNotification()
    func scheduleNotification(title: String, body: String, inDays: Int, atHour: Int, atMinute: Int)
    func cancelMonthlyRecapNotification()
    func cancelAllNotifications()
}
