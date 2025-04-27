//
//  MigrateVehiclesUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct MigrateVehiclesUseCase {
    private let repository: VehicleRepository

    init(repository: VehicleRepository) {
        self.repository = repository
    }

    func execute() throws {
        try repository.migrateVehicles()
    }
}
