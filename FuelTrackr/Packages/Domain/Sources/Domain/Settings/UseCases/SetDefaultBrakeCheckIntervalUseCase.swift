// MARK: - Package: Domain

//
//  SetDefaultBrakeCheckIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct SetDefaultBrakeCheckIntervalUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(_ interval: Int) {
        repository.setDefaultBrakeCheckInterval(interval)
    }
}
