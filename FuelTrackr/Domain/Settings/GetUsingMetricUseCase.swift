//
//  GetUsingMetricUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


import Foundation

struct GetUsingMetricUseCase {
    private let repository = SettingsRepository()

    func execute() -> Bool {
        repository.isUsingMetric()
    }
}