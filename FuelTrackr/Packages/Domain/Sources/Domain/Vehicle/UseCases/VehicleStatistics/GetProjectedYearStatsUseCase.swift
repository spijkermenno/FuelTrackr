//
//  GetProjectedYearStatsUseCase.swift
//  Domain
//
//  Predicts statistics for the **current** calendar year by averaging each
//  calendar month over *completed* previous years. If a month has no
//  historical samples it contributes nothing to the projection. When no
//  completed years exist at all, the use-case falls back to a simple YTD
//  extrapolation. Debug prints log every decision path so you can verify the
//  calculation in Xcode’s console.
//
//  Last revised: 03 Jun 2025.
//

import Foundation
import SwiftData

public struct GetProjectedYearStatsUseCase {
    private let calc: VehicleStatisticsCalculator
    private let calendar: Calendar

    public init(
        repository: any VehicleRepositoryProtocol,
        calendar: Calendar = .current
    ) {
        self.calendar = calendar
        self.calc = VehicleStatisticsCalculator(repository: repository, calendar: calendar)
    }

    public func callAsFunction(context: ModelContext) throws -> VehicleStatisticsUiModel {
        // --- 1. Ensure we have an active vehicle ---
        guard let vehicle = try calc.repository.loadActiveVehicle(context: context) else {
            print("ProjectedYearStats | 🚫 No active vehicle – returning zeros")
            return VehicleStatisticsUiModel(period: .ProjectedYear, distanceDriven: 0, fuelUsed: 0, totalCost: 0)
        }

        let currentYear = calendar.component(.year, from: Date())

        // --- 2. Which years are complete? (strictly before the current year) ---
        //    • vehicle.mileages is now [Mileage]? so unwrap with ?? []
        //    • Each Mileage.date is Date?, so use compactMap to drop nil dates.
        let allDates: [Date] = (vehicle.mileages ?? []).compactMap { $0.date }
        let completedYears: [Int] = Array(
            Set(
                allDates
                    .map { calendar.component(.year, from: $0) }
                    .filter { $0 < currentYear }
            )
        )
        .sorted()

        if completedYears.isEmpty {
            // --- 2a. Fallback – project using monthly YTD averages ---
            //    • Filter to current year; unwrap date similarly
            let thisYearMileages: [Mileage] = (vehicle.mileages ?? [])
                .filter {
                    if let dt = $0.date {
                        return calendar.component(.year, from: dt) == currentYear
                    } else {
                        return false
                    }
                }

            let monthsWithEntries: Set<Int> = Set(
                thisYearMileages
                    .compactMap { $0.date }
                    .map { calendar.component(.month, from: $0) }
            )

            guard !monthsWithEntries.isEmpty else {
                print("ProjectedYearStats | 🚫 No mileage in current year – returning zeros")
                return VehicleStatisticsUiModel(
                    period: .ProjectedYear,
                    distanceDriven: 0,
                    fuelUsed: 0,
                    totalCost: 0
                )
            }

            let monthsCount = Double(monthsWithEntries.count)
            print("ProjectedYearStats | 🕑 No completed years – averaging \(Int(monthsCount)) months and scaling to 12")

            let ytd = calc.yearStat(year: currentYear, period: .YTD, context: context)
            let factor = 12.0 / monthsCount
            print(String(format: "ProjectedYearStats | Monthly-average factor: ×%.2f", factor))

            return VehicleStatisticsUiModel(
                period: .ProjectedYear,
                distanceDriven: ytd.distanceDriven * factor,
                fuelUsed:      ytd.fuelUsed      * factor,
                totalCost:     ytd.totalCost     * factor
            )
        }

        // --- 3. Average each calendar month across completed years ---
        var projectedDistance = 0.0
        var projectedFuel     = 0.0
        var projectedCost     = 0.0

        for month in 1...12 {
            var monthDistances: [Double] = []
            var monthFuels:     [Double] = []
            var monthCosts:     [Double] = []

            for year in completedYears {
                // These repository calls still return non-optional Int/Double
                let km   = Double(calc.repository.getKmDriven(forMonth: month, year: year, context: context))
                let fuel = calc.repository.getFuelUsed(forMonth: month, year: year, context: context)
                let cost = calc.repository.getFuelCost(forMonth: month, year: year, context: context)

                if km > 0 || fuel > 0 || cost > 0 {
                    monthDistances.append(km)
                    monthFuels.append(fuel)
                    monthCosts.append(cost)
                }
            }

            guard !monthDistances.isEmpty else {
                print(String(format: "ProjectedYearStats | Month %02d – no data → skipped", month))
                continue
            }

            let avgDistance = monthDistances.reduce(0, +) / Double(monthDistances.count)
            let avgFuel     = monthFuels.reduce(0, +)     / Double(monthFuels.count)
            let avgCost     = monthCosts.reduce(0, +)     / Double(monthCosts.count)

            print(String(
                format: "ProjectedYearStats | Month %02d – avgDistance: %.1f km, avgFuel: %.2f L, avgCost: €%.2f",
                month, avgDistance, avgFuel, avgCost
            ))

            projectedDistance += avgDistance
            projectedFuel     += avgFuel
            projectedCost     += avgCost
        }

        print(String(
            format: "ProjectedYearStats | 📊 Projection – distance: %.0f km, fuel: %.1f L, cost: €%.2f",
            projectedDistance, projectedFuel, projectedCost
        ))

        return VehicleStatisticsUiModel(
            period: .ProjectedYear,
            distanceDriven: projectedDistance,
            fuelUsed: projectedFuel,
            totalCost: projectedCost
        )
    }
}
