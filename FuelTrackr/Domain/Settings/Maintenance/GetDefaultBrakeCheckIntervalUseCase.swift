//
//  GetDefaultBrakeCheckIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


import Foundation

struct GetDefaultBrakeCheckIntervalUseCase {
    private let repository = SettingsRepository()

    func execute() -> Int {
        repository.defaultBrakeCheckInterval()
    }
}