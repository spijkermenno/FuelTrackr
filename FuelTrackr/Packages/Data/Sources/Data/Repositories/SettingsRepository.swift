// MARK: - Package: Data

//
//  SettingsRepository.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import Domain

public class SettingsRepository: SettingsRepositoryProtocol {
    private let defaults = UserDefaults.standard

    // Keys for UserDefaults
    private enum Keys {
        static let isNotificationsEnabled = "isNotificationsEnabled"
        static let isUsingMetric = "isUsingMetric"
        static let defaultTireInterval = "defaultTireInterval"
        static let defaultOilChangeInterval = "defaultOilChangeInterval"
        static let defaultBrakeCheckInterval = "defaultBrakeCheckInterval"
        static let selectedCurrency = "selectedCurrency"
    }

    private enum DefaultValues {
        static let isNotificationsEnabled = false
        static let isUsingMetric = Locale.current.measurementSystem == .metric
        static let defaultTireInterval = 5000
        static let defaultOilChangeInterval = 10000
        static let defaultBrakeCheckInterval = 20000
    }

    public init() {
        ensureDefaultsExist()
    }

    public func ensureDefaultsExist() {
        if defaults.object(forKey: Keys.isNotificationsEnabled) == nil {
            defaults.set(DefaultValues.isNotificationsEnabled, forKey: Keys.isNotificationsEnabled)
        }
        if defaults.object(forKey: Keys.isUsingMetric) == nil {
            defaults.set(DefaultValues.isUsingMetric, forKey: Keys.isUsingMetric)
        }
        if defaults.object(forKey: Keys.defaultTireInterval) == nil {
            defaults.set(DefaultValues.defaultTireInterval, forKey: Keys.defaultTireInterval)
        }
        if defaults.object(forKey: Keys.defaultOilChangeInterval) == nil {
            defaults.set(DefaultValues.defaultOilChangeInterval, forKey: Keys.defaultOilChangeInterval)
        }
        if defaults.object(forKey: Keys.defaultBrakeCheckInterval) == nil {
            defaults.set(DefaultValues.defaultBrakeCheckInterval, forKey: Keys.defaultBrakeCheckInterval)
        }
    }

    // MARK: - Getters

    public func isNotificationsEnabled() -> Bool {
        defaults.bool(forKey: Keys.isNotificationsEnabled)
    }

    public func isUsingMetric() -> Bool {
        defaults.bool(forKey: Keys.isUsingMetric)
    }

    public func defaultTireInterval() -> Int {
        let value = defaults.integer(forKey: Keys.defaultTireInterval)
        return value == 0 ? DefaultValues.defaultTireInterval : value
    }

    public func defaultOilChangeInterval() -> Int {
        let value = defaults.integer(forKey: Keys.defaultOilChangeInterval)
        return value == 0 ? DefaultValues.defaultOilChangeInterval : value
    }

    public func defaultBrakeCheckInterval() -> Int {
        let value = defaults.integer(forKey: Keys.defaultBrakeCheckInterval)
        return value == 0 ? DefaultValues.defaultBrakeCheckInterval : value
    }

    public func selectedCurrency() -> Currency {
        if let stored = defaults.string(forKey: Keys.selectedCurrency),
           let currency = Currency(rawValue: stored) {
            return currency
        }
        return .euro
    }

    // MARK: - Setters

    public func setNotificationsEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.isNotificationsEnabled)
    }

    public func setUsingMetric(_ metric: Bool) {
        defaults.set(metric, forKey: Keys.isUsingMetric)
    }

    public func setDefaultTireInterval(_ interval: Int) {
        defaults.set(interval, forKey: Keys.defaultTireInterval)
    }

    public func setDefaultOilChangeInterval(_ interval: Int) {
        defaults.set(interval, forKey: Keys.defaultOilChangeInterval)
    }

    public func setDefaultBrakeCheckInterval(_ interval: Int) {
        defaults.set(interval, forKey: Keys.defaultBrakeCheckInterval)
    }

    public func setCurrency(_ currency: Currency) {
        defaults.set(currency.rawValue, forKey: Keys.selectedCurrency)
    }
}
