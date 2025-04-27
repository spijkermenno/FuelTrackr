//
//  UpdateVehiclePurchaseStatusUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct UpdateVehiclePurchaseStatusUseCase {
    private let repository: VehicleRepository

    init(repository: VehicleRepository) {
        self.repository = repository
    }

    func execute(isPurchased: Bool) throws {
        try repository.updateVehiclePurchaseStatus(isPurchased: isPurchased)
    }
}
