//
//  GetDefaultBrakeCheckIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

struct GetDefaultBrakeCheckIntervalUseCase {
    private let repository: SettingsRepository

    init(repository: SettingsRepository) {
        self.repository = repository
    }

    func execute() -> Int {
        return repository.defaultBrakeCheckInterval()
    }
}
