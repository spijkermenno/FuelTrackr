//
//  VehicleStatisticsCalculator.swift
//  Domain
//
//  Created by Menno Spijker on 29/05/2025.
//

import Foundation
import SwiftData

struct VehicleStatisticsCalculator {
    let repository: any VehicleRepositoryProtocol
    let calendar: Calendar

    func monthStat(
        month: Int,
        year: Int,
        period: VehicleStatisticsPeriod,
        context: ModelContext
    ) -> VehicleStatisticsUiModel {
        let distance = repository.getKmDriven(
            forMonth: month,
            year: year,
            context: context
        )
        let fuel = repository.getFuelUsed(
            forMonth: month,
            year: year,
            context: context
        )
        let cost = repository.getFuelCost(
            forMonth: month,
            year: year,
            context: context
        )
        return VehicleStatisticsUiModel(
            period: period,
            distanceDriven: Double(distance),
            fuelUsed: fuel,
            totalCost: cost
        )
    }

    func ytdStat(
        currentMonth: Int,
        year: Int,
        context: ModelContext
    ) -> VehicleStatisticsUiModel {
        var distance = 0
        var fuel = 0.0
        var cost = 0.0
        for m in 1...currentMonth {
            distance += repository.getKmDriven(
                forMonth: m,
                year: year,
                context: context
            )
            fuel += repository.getFuelUsed(
                forMonth: m,
                year: year,
                context: context
            )
            cost += repository.getFuelCost(
                forMonth: m,
                year: year,
                context: context
            )
        }
        return VehicleStatisticsUiModel(
            period: .YTD,
            distanceDriven: Double(distance),
            fuelUsed: fuel,
            totalCost: cost
        )
    }

    func allTimeStat(vehicle: Vehicle) -> VehicleStatisticsUiModel {
        let sorted = vehicle.mileages.sorted { $0.date < $1.date }
        let distance = (sorted.last?.value ?? 0) - (sorted.first?.value ?? 0)
        let fuel = vehicle.fuelUsages.reduce(0) { $0 + $1.liters }
        let cost = vehicle.fuelUsages.reduce(0) { $0 + $1.cost }
        return VehicleStatisticsUiModel(
            period: .AllTime,
            distanceDriven: Double(distance),
            fuelUsed: fuel,
            totalCost: cost
        )
    }
}
