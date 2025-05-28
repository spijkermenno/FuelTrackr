// Package: Domain

//
//  DeleteVehicleUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct DeleteVehicleUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(context: ModelContext) throws {
        try repository.deleteVehicle(context: context)
    }
}
