//
//  GetFuelUsageUseCase.swift
//  Domain
//
//  Created by Menno Spijker on 20/08/2025.
//

import SwiftData

public struct GetFuelUsageUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(id: PersistentIdentifier, context: ModelContext) throws -> FuelUsage? {
        try repository.getFuelUsage(id: id, context: context)
    }
}
