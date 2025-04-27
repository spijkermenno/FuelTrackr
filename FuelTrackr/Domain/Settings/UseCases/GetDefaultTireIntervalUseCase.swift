//
//  GetDefaultTireIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

struct GetDefaultTireIntervalUseCase {
    private let repository: SettingsRepository

    init(repository: SettingsRepository) {
        self.repository = repository
    }

    func execute() -> Int {
        repository.defaultTireInterval()
    }
}
