//
//  SetDefaultTireIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


import Foundation

struct SetDefaultTireIntervalUseCase {
    private let repository: SettingsRepository

    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func execute(_ interval: Int) {
        repository.setDefaultTireInterval(interval)
    }
}
