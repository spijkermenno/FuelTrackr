// Package: Domain

//
//  UpdateVehicleUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

public struct UpdateVehicleUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(vehicle: Vehicle) throws {
        try repository.updateVehicle(vehicle: vehicle)
    }
}
