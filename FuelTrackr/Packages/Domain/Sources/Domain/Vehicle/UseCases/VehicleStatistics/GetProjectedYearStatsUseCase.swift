//
//  GetProjectedYearStatsUseCase.swift
//  Domain
//
//  Predicts statistics for the **current** calendar year by averaging each
//  calendar month over *completed* previous years. If a month has no
//  historical samples it contributes nothing to the projection. When no
//  completed years exist at all, the use‑case falls back to a simple YTD
//  extrapolation. Debug prints log every decision path so you can verify the
//  calculation in Xcode’s console.
//
//  Last revised: 03 Jun 2025.
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
        guard let vehicle = try calc.repository.loadActiveVehicle(context: context) else {
            return VehicleStatisticsUiModel(period: .ProjectedYear, distanceDriven: 0, fuelUsed: 0, totalCost: 0)
        }

        let currentYear = calendar.component(.year, from: Date())

        let completedYears: [Int] = Set(vehicle.mileages.map { calendar.component(.year, from: $0.date) })
            .filter { $0 < currentYear }
            .sorted()

        if completedYears.isEmpty {
            let monthsWithEntries: Set<Int> = Set(vehicle.mileages
                .filter { calendar.component(.year, from: $0.date) == currentYear }
                .map   { calendar.component(.month, from: $0.date) })

            guard !monthsWithEntries.isEmpty else {
                return VehicleStatisticsUiModel(
                    period: .ProjectedYear,
                    distanceDriven: 0,
                    fuelUsed: 0,
                    totalCost: 0
                )
            }

            let monthsCount = Double(monthsWithEntries.count)
            let ytd = calc.yearStat(year: currentYear, period: .YTD, context: context)
            let factor = 12.0 / monthsCount

            return VehicleStatisticsUiModel(
                period: .ProjectedYear,
                distanceDriven: ytd.distanceDriven * factor,
                fuelUsed:      ytd.fuelUsed      * factor,
                totalCost:     ytd.totalCost     * factor
            )
        }

        var projectedDistance = 0.0
        var projectedFuel     = 0.0
        var projectedCost     = 0.0

        for month in 1...12 {
            var monthDistances: [Double] = []
            var monthFuels:     [Double] = []
            var monthCosts:     [Double] = []

            for year in completedYears {
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
                continue
            }

            let avgDistance = monthDistances.reduce(0, +) / Double(monthDistances.count)
            let avgFuel     = monthFuels.reduce(0, +)     / Double(monthFuels.count)
            let avgCost     = monthCosts.reduce(0, +)     / Double(monthCosts.count)

            projectedDistance += avgDistance
            projectedFuel     += avgFuel
            projectedCost     += avgCost
        }

        return VehicleStatisticsUiModel(
            period: .ProjectedYear,
            distanceDriven: projectedDistance,
            fuelUsed: projectedFuel,
            totalCost: projectedCost
        )
    }
}
