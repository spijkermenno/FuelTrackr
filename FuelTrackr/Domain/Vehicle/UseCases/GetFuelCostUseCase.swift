//
//  GetFuelCostUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct GetFuelCostUseCase {
    private let repository: any VehicleRepository

    init(repository: any VehicleRepository) {
        self.repository = repository
    }

    func execute(forMonth month: Int, year: Int? = nil) -> Double {
        repository.getFuelCost(forMonth: month, year: year)
    }
}
