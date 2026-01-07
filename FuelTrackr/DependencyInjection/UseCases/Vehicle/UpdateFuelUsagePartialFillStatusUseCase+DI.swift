//
//  UpdateFuelUsagePartialFillStatusUseCase+DI.swift
//  FuelTrackr
//
//  Created on 2025.
//

import Domain
import Data

extension UpdateFuelUsagePartialFillStatusUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}

