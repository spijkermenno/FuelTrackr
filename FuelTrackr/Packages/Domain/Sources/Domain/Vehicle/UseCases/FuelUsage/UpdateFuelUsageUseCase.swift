//
//  UpdateFuelUsageUseCase.swift
//  Domain
//
//  Created by Menno Spijker on 20/08/2025.
//

import SwiftData

public struct UpdateFuelUsageUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(
        id: PersistentIdentifier,
        liters: Double,
        cost: Double,
        mileageValue: Int,
        context: ModelContext
    ) throws {
        try repository.updateFuelUsage(id: id, liters: liters, cost: cost, mileageValue: mileageValue, context: context)
    }
}
