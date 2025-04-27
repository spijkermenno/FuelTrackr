//
//  DeleteFuelUsageUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct DeleteFuelUsageUseCase {
    private let repository: VehicleRepository

    init(repository: VehicleRepository) {
        self.repository = repository
    }

    func execute(fuelUsage: FuelUsage) throws {
        try repository.deleteFuelUsage(fuelUsage: fuelUsage)
    }
}
