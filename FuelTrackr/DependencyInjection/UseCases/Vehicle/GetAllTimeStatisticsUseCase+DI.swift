//  GetAllTimeStatisticsUseCase+DI.swift
//  FuelTrackr

import Domain
import Data

extension GetAllTimeStatisticsUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
