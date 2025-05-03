// MARK: - Dependency Injection
//
//  DeleteFuelUsageUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import Domain
import Data

extension DeleteFuelUsageUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
