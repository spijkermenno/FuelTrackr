// Package: Domain

//
//  GetFuelUsedUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct GetFuelUsedUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(forMonth month: Int, year: Int? = nil, context: ModelContext) -> Double {
        repository.getFuelUsed(forMonth: month, year: year, context: context)
    }
}
