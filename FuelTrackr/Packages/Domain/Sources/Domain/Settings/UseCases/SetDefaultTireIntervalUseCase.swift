// MARK: - Package: Domain

//
//  SetDefaultTireIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct SetDefaultTireIntervalUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }
    
    public func callAsFunction(_ interval: Int) {
        repository.setDefaultTireInterval(interval)
    }
}
