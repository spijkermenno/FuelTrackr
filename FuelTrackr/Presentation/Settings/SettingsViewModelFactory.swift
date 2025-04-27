//
//  SettingsViewModelFactory.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

struct SettingsViewModelFactory {
    static func make() -> SettingsViewModel {
        let settingsRepository = SettingsRepositoryImpl()

        return SettingsViewModel(
            getIsNotificationsEnabled: GetNotificationsEnabledUseCase(repository: settingsRepository),
            setIsNotificationsEnabled: SetNotificationsEnabledUseCase(repository: settingsRepository),
            getIsUsingMetric: GetUsingMetricUseCase(repository: settingsRepository),
            setIsUsingMetric: SetUsingMetricUseCase(repository: settingsRepository),
            getDefaultTireInterval: GetDefaultTireIntervalUseCase(repository: settingsRepository),
            setDefaultTireInterval: SetDefaultTireIntervalUseCase(repository: settingsRepository),
            getDefaultOilChangeInterval: GetDefaultOilChangeIntervalUseCase(repository: settingsRepository),
            setDefaultOilChangeInterval: SetDefaultOilChangeIntervalUseCase(repository: settingsRepository),
            getDefaultBrakeCheckInterval: GetDefaultBrakeCheckIntervalUseCase(repository: settingsRepository),
            setDefaultBrakeCheckInterval: SetDefaultBrakeCheckIntervalUseCase(repository: settingsRepository),
            getSelectedCurrency: GetSelectedCurrencyUseCase(repository: settingsRepository),
            setSelectedCurrency: SetSelectedCurrencyUseCase(repository: settingsRepository)
        )
    }
}
