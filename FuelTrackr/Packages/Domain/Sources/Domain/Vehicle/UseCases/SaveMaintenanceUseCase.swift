// Package: Domain

//
//  SaveMaintenanceUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct SaveMaintenanceUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(maintenance: Maintenance, context: ModelContext) throws {
        try repository.saveMaintenance(maintenance: maintenance, context: context)
    }
}
