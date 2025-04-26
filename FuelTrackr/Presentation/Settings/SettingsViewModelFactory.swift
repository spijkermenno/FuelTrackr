//
//  SettingsViewModelFactory.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

struct SettingsViewModelFactory {
    static func make() -> SettingsViewModel {
        
        return SettingsViewModel(
            getIsNotificationsEnabled: GetNotificationsEnabledUseCase(),
            setIsNotificationsEnabled: SetNotificationsEnabledUseCase(),
            getIsUsingMetric: GetUsingMetricUseCase(),
            setIsUsingMetric: SetUsingMetricUseCase(),
            getDefaultTireInterval: GetDefaultTireIntervalUseCase(),
            setDefaultTireInterval: SetDefaultTireIntervalUseCase(),
            getDefaultOilChangeInterval: GetDefaultOilChangeIntervalUseCase(),
            setDefaultOilChangeInterval: SetDefaultOilChangeIntervalUseCase(),
            getDefaultBrakeCheckInterval: GetDefaultBrakeCheckIntervalUseCase(),
            setDefaultBrakeCheckInterval: SetDefaultBrakeCheckIntervalUseCase(),
            getSelectedCurrency: GetSelectedCurrencyUseCase(),
            setSelectedCurrency: SetSelectedCurrencyUseCase()
        )
    }
}
