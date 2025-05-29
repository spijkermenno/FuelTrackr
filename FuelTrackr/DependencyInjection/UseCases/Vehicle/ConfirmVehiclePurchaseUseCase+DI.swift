//
//  ConfirmVehiclePurchaseUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 29/05/2025.
//


// MARK: - Dependency Injection
//
//  ConfirmVehiclePurchaseUseCase+DI.swift
//  FuelTrackr
//

import Domain
import Data

extension ConfirmVehiclePurchaseUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}