//
//  GetYearToDateStatisticsUseCase.swift
//  Domain
//
//  Calculates “year-to-date” stats by looking at mileage records in the
//  current year, computing distance from consecutive value differences, then
//  summing fuel and cost month-by-month up to today.
//
//  Last revised: 04 Jun 2025.
//

import Foundation
import SwiftData

public struct GetYearToDateStatisticsUseCase {
    private let calc: VehicleStatisticsCalculator

    public init(
        repository: any VehicleRepositoryProtocol,
        calendar: Calendar = .current
    ) {
        calc = VehicleStatisticsCalculator(repository: repository, calendar: calendar)
    }

    public func callAsFunction(context: ModelContext) throws -> VehicleStatisticsUiModel {
        // 1. Load the active vehicle (or return zeros if none)
        guard let vehicle = try calc.repository.loadActiveVehicle(context: context) else {
            return VehicleStatisticsUiModel(period: .YTD, distanceDriven: 0, fuelUsed: 0, totalCost: 0)
        }

        let now = Date()
        let year = calc.calendar.component(.year, from: now)
        let currentMonth = calc.calendar.component(.month, from: now)

        // 2. Build an array of (date, value) for all mileages in the current year,
        //    dropping any entries where date or value is nil
        let yearTuples: [(date: Date, value: Int)] = (vehicle.mileages ?? []).compactMap { m in
            guard
                let d = m.date,
                let v = m.value,
                calc.calendar.component(.year, from: d) == year
            else {
                return nil
            }
            return (date: d, value: v)
        }

        // 3. Sort by date, then compute distance from consecutive deltas
        let sortedYearTuples = yearTuples.sorted { $0.date < $1.date }

        var distance = 0
        if sortedYearTuples.count >= 2 {
            for idx in 1..<sortedYearTuples.count {
                let prev = sortedYearTuples[idx - 1].value
                let next = sortedYearTuples[idx].value
                distance += (next - prev)
            }
        }

        // 4. Sum fuel and cost month by month up to currentMonth
        var fuel = 0.0
        var cost = 0.0
        for month in 1...currentMonth {
            fuel += calc.repository.getFuelUsed(forMonth: month, year: year, context: context)
            cost += calc.repository.getFuelCost(forMonth: month, year: year, context: context)
        }

        return VehicleStatisticsUiModel(
            period: .YTD,
            distanceDriven: Double(distance),
            fuelUsed: fuel,
            totalCost: cost
        )
    }
}
