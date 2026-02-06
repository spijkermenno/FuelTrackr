// Package: Domain

//
//  UpdateFuelUsagePartialFillStatusUseCase.swift
//  FuelTrackr
//
//  Created on 2025.
//

import Foundation
import SwiftData

public struct UpdateFuelUsagePartialFillStatusUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(id: PersistentIdentifier, isPartialFill: Bool, context: ModelContext) throws {
        try repository.updateFuelUsagePartialFillStatus(id: id, isPartialFill: isPartialFill, context: context)
    }
}

