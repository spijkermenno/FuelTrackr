//
//  MonthlyRecapViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//


import Foundation

class MonthlyRecapViewModel: ObservableObject {
    private let getFuelUsedUseCase: GetFuelUsedUseCase
    private let getFuelCostUseCase: GetFuelCostUseCase
    private let getKmDrivenUseCase: GetKmDrivenUseCase
    private let getAverageFuelUsageUseCase: GetAverageFuelUsageUseCase
    private let getUsingMetricUseCase: GetUsingMetricUseCase

    init(
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
    
    func getKmDriven(month: Int, year: Int?) -> Int {
        getKmDrivenUseCase.execute(forMonth: month, year: year)
    }
    
    func getFuelUsed(month: Int, year: Int?) -> Double {
        getFuelUsedUseCase.execute(forMonth: month, year: year)
    }
    
    func getFuelCost(month: Int, year: Int?) -> Double {
        getFuelCostUseCase.execute(forMonth: month, year: year)
    }
    
    func getAverageFuelUsage(month: Int, year: Int?) -> Double {
        getAverageFuelUsageUseCase.execute(forMonth: month, year: year)
    }
    
    func isUsingMetric() -> Bool {
        getUsingMetricUseCase.execute()
    }
}