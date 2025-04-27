//
//  GetKmDrivenUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

struct GetKmDrivenUseCase {
    private let repository: any VehicleRepository

    init(repository: any VehicleRepository) {
        self.repository = repository
    }

    func execute(forMonth month: Int, year: Int? = nil) -> Int {
        repository.getKmDriven(forMonth: month, year: year)
    }
}
