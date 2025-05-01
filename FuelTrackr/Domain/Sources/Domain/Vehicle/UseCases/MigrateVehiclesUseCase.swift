// Package: Domain

//
//  MigrateVehiclesUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

public struct MigrateVehiclesUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction() throws {
        try repository.migrateVehicles()
    }
}
