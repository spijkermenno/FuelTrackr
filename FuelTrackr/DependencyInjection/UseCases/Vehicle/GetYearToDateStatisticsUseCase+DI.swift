//  GetYearToDateStatisticsUseCase+DI.swift
//  FuelTrackr

import Domain
import Data

extension GetYearToDateStatisticsUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
