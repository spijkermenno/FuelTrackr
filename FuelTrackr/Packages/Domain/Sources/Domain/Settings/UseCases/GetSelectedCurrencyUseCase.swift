// MARK: - Package: Domain

//
//  GetSelectedCurrencyUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct GetSelectedCurrencyUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() -> Currency {
        repository.selectedCurrency()
    }
}
