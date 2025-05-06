// MARK: - Package: Domain

//
//  GetDefaultTireIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct GetDefaultTireIntervalUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() -> Int {
        repository.defaultTireInterval()
    }
}
