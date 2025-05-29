//
//  GetCurrentMonthStatisticsUseCase.swift
//  Domain
//
//  Created by Menno Spijker on 29/05/2025.
//

import Foundation
import SwiftData

public struct GetCurrentMonthStatisticsUseCase {
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
        guard try calc.repository.loadActiveVehicle(context: context) != nil else {
            return VehicleStatisticsUiModel(
                period: .CurrentMonth,
                distanceDriven: 0,
                fuelUsed: 0,
                totalCost: 0
            )
        }
        let now = Date()
        let month = calc.calendar.component(.month, from: now)
        let year = calc.calendar.component(.year, from: now)
        return calc.monthStat(
            month: month,
            year: year,
            period: .CurrentMonth,
            context: context
        )
    }
}
