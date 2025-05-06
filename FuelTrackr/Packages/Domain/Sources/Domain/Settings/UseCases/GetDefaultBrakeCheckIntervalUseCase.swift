// MARK: - Package: Domain

//
//  GetDefaultBrakeCheckIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct GetDefaultBrakeCheckIntervalUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() -> Int {
        repository.defaultBrakeCheckInterval()
    }
}
