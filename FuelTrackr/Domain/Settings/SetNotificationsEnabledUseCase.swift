//
//  SetNotificationsEnabledUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


import Foundation

struct SetNotificationsEnabledUseCase {
    private let repository = SettingsRepository()

    func execute(_ enabled: Bool) {
        repository.setNotificationsEnabled(enabled)
    }
}