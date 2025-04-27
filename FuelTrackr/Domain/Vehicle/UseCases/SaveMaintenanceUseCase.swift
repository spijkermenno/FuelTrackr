//
//  SaveMaintenanceUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct SaveMaintenanceUseCase {
    private let repository: VehicleRepository

    init(repository: VehicleRepository) {
        self.repository = repository
    }

    func execute(maintenance: Maintenance) throws {
        try repository.saveMaintenance(maintenance: maintenance)
    }
}
