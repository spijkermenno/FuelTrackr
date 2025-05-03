// MARK: - Dependency Injection
//
//  LoadActiveVehicleUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import Domain
import Data


extension LoadActiveVehicleUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
