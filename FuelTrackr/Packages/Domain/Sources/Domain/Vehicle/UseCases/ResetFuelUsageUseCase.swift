// Package: Domain

//
//  ResetFuelUsageUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct ResetFuelUsageUseCase {
    private let repository: VehicleRepositoryProtocol

    public init(repository: VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(context: ModelContext) throws {
        try repository.resetFuelUsage(context: context)
    }
}
