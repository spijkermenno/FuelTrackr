// MARK: - Package: Domain

//
//  SettingsRepository.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

public protocol SettingsRepositoryProtocol {
    func ensureDefaultsExist()
    func isNotificationsEnabled() -> Bool
    func isUsingMetric() -> Bool
    func defaultTireInterval() -> Int
    func defaultOilChangeInterval() -> Int
    func defaultBrakeCheckInterval() -> Int
    func selectedCurrency() -> Currency

    func setNotificationsEnabled(_ enabled: Bool)
    func setUsingMetric(_ metric: Bool)
    func setDefaultTireInterval(_ interval: Int)
    func setDefaultOilChangeInterval(_ interval: Int)
    func setDefaultBrakeCheckInterval(_ interval: Int)
    func setCurrency(_ currency: Currency)
}
