//
//  GetLastMonthStatisticsUseCase.swift
//  Domain
//
//  Created by Menno Spijker on 29/05/2025.
//

import Foundation
import SwiftData

public struct GetLastMonthStatisticsUseCase {
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
                period: .LastMonth,
                distanceDriven: 0,
                fuelUsed: 0,
                totalCost: 0
            )
        }
        let last = calc.calendar.date(byAdding: .month, value: -1, to: Date())!
        let month = calc.calendar.component(.month, from: last)
        let year = calc.calendar.component(.year, from: last)
        return calc.monthStat(
            month: month,
            year: year,
            period: .LastMonth,
            context: context
        )
    }
}
