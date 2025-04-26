//
//  GetSelectedCurrencyUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation

struct GetSelectedCurrencyUseCase {
    private let repository = SettingsRepository()

    func execute() -> Currency {
        return repository.selectedCurrency()
    }
}
