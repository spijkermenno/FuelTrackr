//
//  VehicleStatisticsCalculator.swift
//  Domain
//
//  Kotlin-style formatted Swift (4-space indents, compact comments).
//
//  Created by Menno Spijker on 29/05/2025.
//  Reformatted by ChatGPT on 03/06/2025.
//
//  Updated on 04/06/2025 to handle optional relationships and attributes.
//

import Foundation
import SwiftData

struct VehicleStatisticsCalculator {
    let repository: any VehicleRepositoryProtocol
    let calendar: Calendar

    // MARK: Monthly stat
    func monthStat(
        month: Int,
        year: Int,
        period: VehicleStatisticsPeriod,
        context: ModelContext
    ) -> VehicleStatisticsUiModel {
        let distance = repository.getKmDriven(forMonth: month, year: year, context: context)
        let fuel = repository.getFuelUsed(forMonth: month, year: year, context: context)
        let cost = repository.getFuelCost(forMonth: month, year: year, context: context)
        return VehicleStatisticsUiModel(
            period: period,
            distanceDriven: Double(distance),
            fuelUsed: fuel,
            totalCost: cost
        )
    }

    // MARK: Full-year stat
    func yearStat(
        year: Int,
        period: VehicleStatisticsPeriod,
        context: ModelContext
    ) -> VehicleStatisticsUiModel {
        var distance = 0
        var fuel = 0.0
        var cost = 0.0

        for month in 1...12 {
            distance += repository.getKmDriven(forMonth: month, year: year, context: context)
            fuel += repository.getFuelUsed(forMonth: month, year: year, context: context)
            cost += repository.getFuelCost(forMonth: month, year: year, context: context)
        }

        return VehicleStatisticsUiModel(
            period: period,
            distanceDriven: Double(distance),
            fuelUsed: fuel,
            totalCost: cost
        )
    }

    // MARK: All-time stat (per-month breakdown aggregated via deltas)
    func allTimeStat(vehicle: Vehicle) -> VehicleStatisticsUiModel {
        // Month key (yyyy-MM)
        let df = DateFormatter()
        df.calendar = calendar
        df.dateFormat = "yyyy-MM"

        // 1. Build sorted list of non-nil (date, value) tuples from mileages
        let dateValueTuples: [(date: Date, value: Int)] = (vehicle.mileages ?? []).compactMap { m in
            guard
                let d = m.date,
                let v = m.value
            else {
                return nil
            }
            return (date: d, value: v)
        }
        let sortedTuples = dateValueTuples.sorted { $0.date < $1.date }

        // 2. Compute distance per month via consecutive mileage entries
        var distancePerMonth: [String: Int] = [:]
        if sortedTuples.count > 1 {
            for idx in 1..<sortedTuples.count {
                let previousValue = sortedTuples[idx - 1].value
                let currentValue = sortedTuples[idx].value
                let delta = currentValue - previousValue
                let key = df.string(from: sortedTuples[idx].date)
                distancePerMonth[key, default: 0] += delta
            }
        }

        // 3. Build fuelPerMonth and costPerMonth from non-nil usages
        var fuelPerMonth: [String: Double] = [:]
        var costPerMonth: [String: Double] = [:]
        for usage in (vehicle.fuelUsages ?? []) {
            guard
                let d = usage.date,
                let liters = usage.liters,
                let c = usage.cost
            else {
                continue
            }
            let key = df.string(from: d)
            fuelPerMonth[key, default: 0] += liters
            costPerMonth[key, default: 0] += c
        }

        // 4. Aggregate grand totals across all keys
        let monthKeys = Set(distancePerMonth.keys)
            .union(fuelPerMonth.keys)
            .union(costPerMonth.keys)
            .sorted()
        var distanceTotal = 0
        var fuelTotal = 0.0
        var costTotal = 0.0

        for key in monthKeys {
            distanceTotal += distancePerMonth[key] ?? 0
            fuelTotal += fuelPerMonth[key] ?? 0
            costTotal += costPerMonth[key] ?? 0
        }

        return VehicleStatisticsUiModel(
            period: .AllTime,
            distanceDriven: Double(distanceTotal),
            fuelUsed: fuelTotal,
            totalCost: costTotal
        )
    }
}
