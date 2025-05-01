// Package: Domain

//
//  SaveFuelUsageUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

public struct SaveFuelUsageUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(liters: Double, cost: Double, mileageValue: Int) throws {
        try repository.saveFuelUsage(liters: liters, cost: cost, mileageValue: mileageValue)
    }
}
