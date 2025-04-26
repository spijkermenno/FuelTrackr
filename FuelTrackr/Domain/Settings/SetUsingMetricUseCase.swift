//
//  SetUsingMetricUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


import Foundation

struct SetUsingMetricUseCase {
    private let repository = SettingsRepository()

    func execute(_ metric: Bool) {
        repository.setUsingMetric(metric)
    }
}
