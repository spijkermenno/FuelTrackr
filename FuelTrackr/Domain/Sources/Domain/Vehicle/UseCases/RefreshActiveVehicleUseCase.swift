//
//  RefreshActiveVehicleUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

public struct RefreshActiveVehicleUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() throws -> Vehicle? {
        try repository.refreshActiveVehicle()
    }
}
