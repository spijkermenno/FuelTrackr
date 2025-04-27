//
//  LoadActiveVehicleUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct LoadActiveVehicleUseCase {
    private let repository: any VehicleRepository

    init(repository: any VehicleRepository) {
        self.repository = repository
    }

    func execute() throws -> Vehicle? {
        try repository.loadActiveVehicle()
    }
}
