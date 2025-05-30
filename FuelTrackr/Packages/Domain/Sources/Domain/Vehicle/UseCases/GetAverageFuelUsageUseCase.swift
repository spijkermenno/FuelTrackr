// Package: Domain

//
//  GetAverageFuelUsageUseCase.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

public struct GetAverageFuelUsageUseCase {
    private let repository: any VehicleRepositoryProtocol

    public init(repository: any VehicleRepositoryProtocol) {
        self.repository = repository
    }

    public func callAsFunction(forMonth month: Int, year: Int? = nil, context: ModelContext) -> Double {
        repository.getAverageFuelUsage(forMonth: month, year: year, context: context)
    }
}
