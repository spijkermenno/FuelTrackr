// MARK: - Package: Presentation

//
//  SettingsViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation
import Domain

public class SettingsViewModel: ObservableObject {
    // MARK: - UseCases
    private let getIsNotificationsEnabled: GetNotificationsEnabledUseCase
    private let setIsNotificationsEnabled: SetNotificationsEnabledUseCase
    private let getIsUsingMetric: GetUsingMetricUseCase
    private let setIsUsingMetric: SetUsingMetricUseCase
    private let getDefaultTireInterval: GetDefaultTireIntervalUseCase
    private let setDefaultTireInterval: SetDefaultTireIntervalUseCase
    private let getDefaultOilChangeInterval: GetDefaultOilChangeIntervalUseCase
    private let setDefaultOilChangeInterval: SetDefaultOilChangeIntervalUseCase
    private let getDefaultBrakeCheckInterval: GetDefaultBrakeCheckIntervalUseCase
    private let setDefaultBrakeCheckInterval: SetDefaultBrakeCheckIntervalUseCase
    private let getSelectedCurrency: GetSelectedCurrencyUseCase
    private let setSelectedCurrency: SetSelectedCurrencyUseCase

    // MARK: - Published State
    @Published public var isNotificationsEnabled: Bool = false
    @Published public var isUsingMetric: Bool = true
    @Published public var defaultTireInterval: Int = 0
    @Published public var defaultOilChangeInterval: Int = 0
    @Published public var defaultBrakeCheckInterval: Int = 0
    @Published public var selectedCurrency: Currency = .euro

    // MARK: - Init
    public init(
        getIsNotificationsEnabled: GetNotificationsEnabledUseCase,
        setIsNotificationsEnabled: SetNotificationsEnabledUseCase,
        getIsUsingMetric: GetUsingMetricUseCase,
        setIsUsingMetric: SetUsingMetricUseCase,
        getDefaultTireInterval: GetDefaultTireIntervalUseCase,
        setDefaultTireInterval: SetDefaultTireIntervalUseCase,
        getDefaultOilChangeInterval: GetDefaultOilChangeIntervalUseCase,
        setDefaultOilChangeInterval: SetDefaultOilChangeIntervalUseCase,
        getDefaultBrakeCheckInterval: GetDefaultBrakeCheckIntervalUseCase,
        setDefaultBrakeCheckInterval: SetDefaultBrakeCheckIntervalUseCase,
        getSelectedCurrency: GetSelectedCurrencyUseCase,
        setSelectedCurrency: SetSelectedCurrencyUseCase
    ) {
        self.getIsNotificationsEnabled = getIsNotificationsEnabled
        self.setIsNotificationsEnabled = setIsNotificationsEnabled
        self.getIsUsingMetric = getIsUsingMetric
        self.setIsUsingMetric = setIsUsingMetric
        self.getDefaultTireInterval = getDefaultTireInterval
        self.setDefaultTireInterval = setDefaultTireInterval
        self.getDefaultOilChangeInterval = getDefaultOilChangeInterval
        self.setDefaultOilChangeInterval = setDefaultOilChangeInterval
        self.getDefaultBrakeCheckInterval = getDefaultBrakeCheckInterval
        self.setDefaultBrakeCheckInterval = setDefaultBrakeCheckInterval
        self.getSelectedCurrency = getSelectedCurrency
        self.setSelectedCurrency = setSelectedCurrency

        loadSettings()
    }

    // MARK: - Functions
    public func loadSettings() {
        isNotificationsEnabled = getIsNotificationsEnabled()
        isUsingMetric = getIsUsingMetric()
        defaultTireInterval = getDefaultTireInterval()
        defaultOilChangeInterval = getDefaultOilChangeInterval()
        defaultBrakeCheckInterval = getDefaultBrakeCheckInterval()
        selectedCurrency = getSelectedCurrency()
    }

    public func updateNotifications(_ isEnabled: Bool) {
        isNotificationsEnabled = isEnabled
        setIsNotificationsEnabled(isEnabled)
    }

    public func updateMetricSystem(_ isMetric: Bool) {
        isUsingMetric = isMetric
        setIsUsingMetric(isMetric)
    }

    public func updateTireInterval(_ interval: Int) {
        defaultTireInterval = interval
        setDefaultTireInterval(interval)
    }

    public func updateOilChangeInterval(_ interval: Int) {
        defaultOilChangeInterval = interval
        setDefaultOilChangeInterval(interval)
    }

    public func updateBrakeCheckInterval(_ interval: Int) {
        defaultBrakeCheckInterval = interval
        setDefaultBrakeCheckInterval(interval)
    }

    public func updateCurrency(_ currency: Currency) {
        selectedCurrency = currency
        setSelectedCurrency(currency)
    }
}
