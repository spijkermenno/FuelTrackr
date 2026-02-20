// MARK: - Dependency Injection
//
//  UpdateOdometerUseCase+DI.swift
//  FuelTrackr
//

import Domain
import Data

extension UpdateOdometerUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
