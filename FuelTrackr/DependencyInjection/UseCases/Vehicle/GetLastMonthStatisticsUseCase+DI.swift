//  GetLastMonthStatisticsUseCase+DI.swift
//  FuelTrackr

import Domain
import Data

extension GetLastMonthStatisticsUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
