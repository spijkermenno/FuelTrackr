// MARK: - Package: Domain

//
//  SetDefaultOilChangeIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct SetDefaultOilChangeIntervalUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }
    
    public func callAsFunction(_ interval: Int) {
        repository.setDefaultOilChangeInterval(interval)
    }
}
