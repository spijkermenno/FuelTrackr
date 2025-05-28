// MARK: - Package: Domain

//
//  GetDefaultOilChangeIntervalUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct GetDefaultOilChangeIntervalUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() -> Int {
        repository.defaultOilChangeInterval()
    }
}
