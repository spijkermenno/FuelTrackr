// Package: Domain

//
//  DeleteMaintenanceUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct DeleteMaintenanceUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(maintenance: Maintenance, context: ModelContext) throws {
        try repository.deleteMaintenance(maintenance: maintenance, context: context)
    }
}
