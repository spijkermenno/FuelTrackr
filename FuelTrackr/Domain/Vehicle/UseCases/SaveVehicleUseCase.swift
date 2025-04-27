//
//  SaveVehicleUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct SaveVehicleUseCase {
    private let repository: any VehicleRepository

    init(repository: any VehicleRepository) {
        self.repository = repository
    }

    func execute(vehicle: Vehicle, initialMileage: Int) throws {
        try repository.saveVehicle(vehicle: vehicle, initialMileage: initialMileage)
    }
}
