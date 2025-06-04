//
//  GetCurrentMonthStatisticsUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 29/05/2025.
//

import Domain
import Data

extension GetCurrentMonthStatisticsUseCase {
    public init() {
        self.init(repository: VehicleRepository())
    }
}
