//
//  GetAllTimeStatisticsUseCase.swift
//  Domain
//
//  Created by Menno Spijker on 29/05/2025.
//

import Foundation
import SwiftData

public struct GetAllTimeStatisticsUseCase {
    private let calc: VehicleStatisticsCalculator

    public init(
        repository: any VehicleRepositoryProtocol,
        calendar: Calendar = .current
    ) {
        calc = VehicleStatisticsCalculator(
            repository: repository,
            calendar: calendar
        )
    }

    public func callAsFunction(context: ModelContext) throws -> VehicleStatisticsUiModel {
        guard let vehicle = try calc.repository.loadActiveVehicle(context: context) else {
            return VehicleStatisticsUiModel(
                period: .AllTime,
                distanceDriven: 0,
                fuelUsed: 0,
                totalCost: 0
            )
        }
        return calc.allTimeStat(vehicle: vehicle)
    }
}
