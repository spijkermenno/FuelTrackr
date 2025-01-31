//
//  SettingsRepository.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/01/2025.
//

import Foundation

class SettingsRepository {
    private let defaults = UserDefaults.standard

    // Keys for UserDefaults
    private enum Keys {
        static let isNotificationsEnabled = "isNotificationsEnabled"
        static let isUsingMetric = "isUsingMetric"
        static let defaultTireInterval = "defaultTireInterval"
        static let defaultOilChangeInterval = "defaultOilChangeInterval"
        static let defaultBrakeCheckInterval = "defaultBrakeCheckInterval"
    }

    // Default values
    private enum DefaultValues {
        static let isNotificationsEnabled = false
        static let isUsingMetric = Locale.current.measurementSystem == .metric
        static let defaultTireInterval = 5000
        static let defaultOilChangeInterval = 10000
        static let defaultBrakeCheckInterval = 20000
    }

    init() {
        ensureDefaultsExist()
    }

    // MARK: - Ensure Defaults Exist
    func ensureDefaultsExist() {
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

    func isNotificationsEnabled() -> Bool {
        defaults.bool(forKey: Keys.isNotificationsEnabled)
    }

    func isUsingMetric() -> Bool {
        defaults.bool(forKey: Keys.isUsingMetric)
    }

    func defaultTireInterval() -> Int {
        defaults.integer(forKey: Keys.defaultTireInterval) == 0 ? DefaultValues.defaultTireInterval : defaults.integer(forKey: Keys.defaultTireInterval)
    }

    func defaultOilChangeInterval() -> Int {
        defaults.integer(forKey: Keys.defaultOilChangeInterval) == 0 ? DefaultValues.defaultOilChangeInterval : defaults.integer(forKey: Keys.defaultOilChangeInterval)
    }

    func defaultBrakeCheckInterval() -> Int {
        defaults.integer(forKey: Keys.defaultBrakeCheckInterval) == 0 ? DefaultValues.defaultBrakeCheckInterval : defaults.integer(forKey: Keys.defaultBrakeCheckInterval)
    }

    // MARK: - Setters

    func setNotificationsEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.isNotificationsEnabled)
    }

    func setUsingMetric(_ metric: Bool) {
        defaults.set(metric, forKey: Keys.isUsingMetric)
    }

    func setDefaultTireInterval(_ interval: Int) {
        defaults.set(interval, forKey: Keys.defaultTireInterval)
    }

    func setDefaultOilChangeInterval(_ interval: Int) {
        defaults.set(interval, forKey: Keys.defaultOilChangeInterval)
    }

    func setDefaultBrakeCheckInterval(_ interval: Int) {
        defaults.set(interval, forKey: Keys.defaultBrakeCheckInterval)
    }
}
