//
//  SettingsViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


// Presentation/ViewModels/SettingsViewModel.swift

import Foundation

class SettingsViewModel: ObservableObject {
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
    @Published var isNotificationsEnabled: Bool = false
    @Published var isUsingMetric: Bool = true
    @Published var defaultTireInterval: Int = 0
    @Published var defaultOilChangeInterval: Int = 0
    @Published var defaultBrakeCheckInterval: Int = 0
    @Published var selectedCurrency: Currency = .euro

    // MARK: - Init
    init(
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
    func loadSettings() {
        isNotificationsEnabled = getIsNotificationsEnabled.execute()
        isUsingMetric = getIsUsingMetric.execute()
        defaultTireInterval = getDefaultTireInterval.execute()
        defaultOilChangeInterval = getDefaultOilChangeInterval.execute()
        defaultBrakeCheckInterval = getDefaultBrakeCheckInterval.execute()
        selectedCurrency = getSelectedCurrency.execute()
    }

    func updateNotifications(_ isEnabled: Bool) {
        isNotificationsEnabled = isEnabled
        setIsNotificationsEnabled.execute(isEnabled)
    }

    func updateMetricSystem(_ isMetric: Bool) {
        isUsingMetric = isMetric
        setIsUsingMetric.execute(isMetric)
    }

    func updateTireInterval(_ interval: Int) {
        defaultTireInterval = interval
        setDefaultTireInterval.execute(interval)
    }

    func updateOilChangeInterval(_ interval: Int) {
        defaultOilChangeInterval = interval
        setDefaultOilChangeInterval.execute(interval)
    }

    func updateBrakeCheckInterval(_ interval: Int) {
        defaultBrakeCheckInterval = interval
        setDefaultBrakeCheckInterval.execute(interval)
    }

    func updateCurrency(_ currency: Currency) {
        selectedCurrency = currency
        setSelectedCurrency.execute(currency: currency)
    }
}
