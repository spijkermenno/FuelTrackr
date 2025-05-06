// Package: Domain

//
//  SaveVehicleUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct SaveVehicleUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(vehicle: Vehicle, initialMileage: Int, context: ModelContext) throws {
        try repository.saveVehicle(vehicle: vehicle, initialMileage: initialMileage, context: context)
    }
}
