// Package: Domain
//
//  UpdateOdometerUseCase.swift
//  FuelTrackr
//

import Foundation
import SwiftData

public struct UpdateOdometerUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(vehicle: Vehicle, newValue: Int, context: ModelContext) throws {
        try repository.updateOdometer(vehicle: vehicle, newValue: newValue, context: context)
    }
}
