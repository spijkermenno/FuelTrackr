// Package: Domain

//
//  DeleteFuelUsageUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

public struct DeleteFuelUsageUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(fuelUsage: FuelUsage) throws {
        try repository.deleteFuelUsage(fuelUsage: fuelUsage)
    }
}
