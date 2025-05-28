// MARK: - Dependency Injection
//
//  DeleteMaintenanceUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import Domain
import Data

extension DeleteMaintenanceUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
