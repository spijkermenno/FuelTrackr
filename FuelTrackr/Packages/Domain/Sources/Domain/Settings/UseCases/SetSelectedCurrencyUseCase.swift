// MARK: - Package: Domain

//
//  SetSelectedCurrencyUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

public struct SetSelectedCurrencyUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(_ currency: Currency) {
        repository.setCurrency(currency)
    }
}
