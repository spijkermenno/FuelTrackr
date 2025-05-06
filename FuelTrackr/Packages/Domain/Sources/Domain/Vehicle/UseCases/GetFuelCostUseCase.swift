// Package: Domain

//
//  GetFuelCostUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct GetFuelCostUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(forMonth month: Int, year: Int? = nil, context: ModelContext) -> Double {
        repository.getFuelCost(forMonth: month, year: year, context: context)
    }
}
