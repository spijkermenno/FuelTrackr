// MARK: - Dependency Injection
//
//  ResetFuelUsageUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import Domain
import Data


extension ResetFuelUsageUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
