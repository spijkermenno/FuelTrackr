// Package: Domain

//
//  SaveFuelUsageUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct SaveFuelUsageUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(liters: Double, cost: Double, mileageValue: Int, date: Date, context: ModelContext) throws {
        try repository.saveFuelUsage(liters: liters, cost: cost, mileageValue: mileageValue, date: date, context: context)
    }
}
