// MARK: - Dependency Injection
//
//  GetKmDrivenUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import Domain
import Data


extension GetKmDrivenUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
