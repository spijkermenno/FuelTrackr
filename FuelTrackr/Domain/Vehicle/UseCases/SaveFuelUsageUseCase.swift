//
//  SaveFuelUsageUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct SaveFuelUsageUseCase {
    private let repository: VehicleRepository

    init(repository: VehicleRepository) {
        self.repository = repository
    }

    func execute(liters: Double, cost: Double, mileageValue: Int) throws {
        try repository.saveFuelUsage(liters: liters, cost: cost, mileageValue: mileageValue)
    }
}
