//
//  UpdateVehicleUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct UpdateVehicleUseCase {
    private let repository: any VehicleRepository

    init(repository: any VehicleRepository) {
        self.repository = repository
    }

    func execute(vehicle: Vehicle) throws {
        try repository.updateVehicle(vehicle: vehicle)
    }
}
