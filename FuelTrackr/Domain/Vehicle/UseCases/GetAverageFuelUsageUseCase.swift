//
//  GetAverageFuelUsageUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct GetAverageFuelUsageUseCase {
    private let repository: any VehicleRepository

    init(repository: any VehicleRepository) {
        self.repository = repository
    }

    func execute(forMonth month: Int, year: Int? = nil) -> Double {
        repository.getAverageFuelUsage(forMonth: month, year: year)
    }
}
