//
//  SetDefaultTireIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


import Foundation

struct SetDefaultTireIntervalUseCase {
    private let repository = SettingsRepository()

    func execute(_ interval: Int) {
        repository.setDefaultTireInterval(interval)
    }
}