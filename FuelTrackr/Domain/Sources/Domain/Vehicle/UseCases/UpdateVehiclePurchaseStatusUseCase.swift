// Package: Domain

//
//  UpdateVehiclePurchaseStatusUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

public struct UpdateVehiclePurchaseStatusUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(isPurchased: Bool) throws {
        try repository.updateVehiclePurchaseStatus(isPurchased: isPurchased)
    }
}
