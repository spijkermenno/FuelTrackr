// MARK: - Package: Presentation
//
//  MonthlyRecapViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import Domain

public final class MonthlyRecapViewModel: ObservableObject {
    private let getFuelUsedUseCase: GetFuelUsedUseCase
    private let getFuelCostUseCase: GetFuelCostUseCase
    private let getKmDrivenUseCase: GetKmDrivenUseCase
    private let getAverageFuelUsageUseCase: GetAverageFuelUsageUseCase
    private let getUsingMetricUseCase: GetUsingMetricUseCase

    public init(
        getFuelUsedUseCase: GetFuelUsedUseCase,
        getFuelCostUseCase: GetFuelCostUseCase,
        getKmDrivenUseCase: GetKmDrivenUseCase,
        getAverageFuelUsageUseCase: GetAverageFuelUsageUseCase,
        getUsingMetricUseCase: GetUsingMetricUseCase
    ) {
        self.getFuelUsedUseCase = getFuelUsedUseCase
        self.getFuelCostUseCase = getFuelCostUseCase
        self.getKmDrivenUseCase = getKmDrivenUseCase
        self.getAverageFuelUsageUseCase = getAverageFuelUsageUseCase
        self.getUsingMetricUseCase = getUsingMetricUseCase
    }

    public func getKmDriven(month: Int, year: Int?) -> Int {
        getKmDrivenUseCase(forMonth: month, year: year)
    }

    public func getFuelUsed(month: Int, year: Int?) -> Double {
        getFuelUsedUseCase(forMonth: month, year: year)
    }

    public func getFuelCost(month: Int, year: Int?) -> Double {
        getFuelCostUseCase(forMonth: month, year: year)
    }

    public func getAverageFuelUsage(month: Int, year: Int?) -> Double {
        getAverageFuelUsageUseCase(forMonth: month, year: year)
    }

    public func isUsingMetric() -> Bool {
        getUsingMetricUseCase()
    }
}
