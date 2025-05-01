// MARK: - Package: Domain

//
//  SetUsingMetricUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct SetUsingMetricUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }
    
    public func callAsFunction(_ metric: Bool) {
        repository.setUsingMetric(metric)
    }
}
