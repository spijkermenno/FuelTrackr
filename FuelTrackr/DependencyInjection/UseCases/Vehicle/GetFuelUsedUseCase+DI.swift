// MARK: - Dependency Injection
//
//  GetFuelUsedUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import Domain
import Data


extension GetFuelUsedUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
