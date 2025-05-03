// MARK: - Dependency Injection
//
//  MigrateVehiclesUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import Domain
import Data


extension MigrateVehiclesUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
