// MARK: - Dependency Injection
//
//  SaveVehicleUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import Domain
import Data


extension SaveVehicleUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
