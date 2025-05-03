// MARK: - Package: Domain

//
//  GetUsingMetricUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct GetUsingMetricUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() -> Bool {
        repository.isUsingMetric()
    }
}
