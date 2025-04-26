//
//  SetSelectedCurrencyUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

struct SetSelectedCurrencyUseCase {
    private let repository = SettingsRepository()

    func execute(currency: Currency) {
        repository.setCurrency(currency)
    }
}
