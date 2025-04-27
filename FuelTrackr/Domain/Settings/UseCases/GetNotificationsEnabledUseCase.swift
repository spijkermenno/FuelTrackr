//
//  GetNotificationsEnabledUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


import Foundation

struct GetNotificationsEnabledUseCase {
    private let repository: SettingsRepository

    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute() -> Bool {
        repository.isNotificationsEnabled()
    }
}
