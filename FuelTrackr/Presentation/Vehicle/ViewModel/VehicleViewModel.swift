//
//  VehicleViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/04/2025.
//

import SwiftUI
import Domain
import SwiftData

public final class VehicleViewModel: ObservableObject {
    @Published public var activeVehicleID: PersistentIdentifier?
    @Published public var refreshID = UUID()
    
    private var cachedMonthlySummaries: [MonthlyFuelSummaryUiModel]?
    private var cachedMonthlySummariesVehicleID: PersistentIdentifier?
    private var cachedProjectedYearStats: VehicleStatisticsUiModel?
    private var cachedProjectedYearStatsVehicleID: PersistentIdentifier?

    private let loadActiveVehicleUseCase: LoadActiveVehicleUseCase
    private let saveVehicleUseCase: SaveVehicleUseCase
    private let updateVehicleUseCase: UpdateVehicleUseCase
    private let updateOdometerUseCase: UpdateOdometerUseCase
    private let deleteVehicleUseCase: DeleteVehicleUseCase
    private let saveFuelUsageUseCase: SaveFuelUsageUseCase
    private let deleteFuelUsageUseCase: DeleteFuelUsageUseCase
    private let resetFuelUsageUseCase: ResetFuelUsageUseCase
    private let saveMaintenanceUseCase: SaveMaintenanceUseCase
    private let deleteMaintenanceUseCase: DeleteMaintenanceUseCase
    private let resetMaintenanceUseCase: ResetMaintenanceUseCase
    private let updateVehiclePurchaseStatusUseCase: UpdateVehiclePurchaseStatusUseCase
    private let migrateVehiclesUseCase: MigrateVehiclesUseCase
    private let getFuelUsedUseCase: GetFuelUsedUseCase
    private let getFuelCostUseCase: GetFuelCostUseCase
    private let getKmDrivenUseCase: GetKmDrivenUseCase
    private let getAverageFuelUsageUseCase: GetAverageFuelUsageUseCase
    private let getUsingMetricUseCase: GetUsingMetricUseCase
    private let getCurrentMonthStatsUseCase: GetCurrentMonthStatisticsUseCase
    private let getLastMonthStatsUseCase: GetLastMonthStatisticsUseCase
    private let getYtdStatsUseCase: GetYearToDateStatisticsUseCase
    private let getAllTimeStatsUseCase: GetAllTimeStatisticsUseCase
    private let getProjectedYearStatsUseCase: GetProjectedYearStatsUseCase
    private let confirmVehiclePurchaseUseCase: ConfirmVehiclePurchaseUseCase
    private let getFuelUsageUseCase: GetFuelUsageUseCase
    private let updateFuelUsageUseCase: UpdateFuelUsageUseCase
    private let updateFuelUsagePartialFillStatusUseCase: UpdateFuelUsagePartialFillStatusUseCase
    
    public var hasActiveVehicle: Bool { activeVehicleID != nil }
    public var isUsingMetric: Bool { getUsingMetricUseCase() }
    
    public init(
        loadActiveVehicleUseCase: LoadActiveVehicleUseCase = LoadActiveVehicleUseCase(),
        saveVehicleUseCase: SaveVehicleUseCase = SaveVehicleUseCase(),
        updateVehicleUseCase: UpdateVehicleUseCase = UpdateVehicleUseCase(),
        updateOdometerUseCase: UpdateOdometerUseCase = UpdateOdometerUseCase(),
        deleteVehicleUseCase: DeleteVehicleUseCase = DeleteVehicleUseCase(),
        saveFuelUsageUseCase: SaveFuelUsageUseCase = SaveFuelUsageUseCase(),
        deleteFuelUsageUseCase: DeleteFuelUsageUseCase = DeleteFuelUsageUseCase(),
        resetFuelUsageUseCase: ResetFuelUsageUseCase = ResetFuelUsageUseCase(),
        saveMaintenanceUseCase: SaveMaintenanceUseCase = SaveMaintenanceUseCase(),
        deleteMaintenanceUseCase: DeleteMaintenanceUseCase = DeleteMaintenanceUseCase(),
        resetMaintenanceUseCase: ResetMaintenanceUseCase = ResetMaintenanceUseCase(),
        updateVehiclePurchaseStatusUseCase: UpdateVehiclePurchaseStatusUseCase = UpdateVehiclePurchaseStatusUseCase(),
        migrateVehiclesUseCase: MigrateVehiclesUseCase = MigrateVehiclesUseCase(),
        getFuelUsedUseCase: GetFuelUsedUseCase = GetFuelUsedUseCase(),
        getFuelCostUseCase: GetFuelCostUseCase = GetFuelCostUseCase(),
        getKmDrivenUseCase: GetKmDrivenUseCase = GetKmDrivenUseCase(),
        getAverageFuelUsageUseCase: GetAverageFuelUsageUseCase = GetAverageFuelUsageUseCase(),
        getUsingMetricUseCase: GetUsingMetricUseCase = GetUsingMetricUseCase(),
        getCurrentMonthStatsUseCase: GetCurrentMonthStatisticsUseCase = GetCurrentMonthStatisticsUseCase(),
        getLastMonthStatsUseCase: GetLastMonthStatisticsUseCase = GetLastMonthStatisticsUseCase(),
        getYtdStatsUseCase: GetYearToDateStatisticsUseCase = GetYearToDateStatisticsUseCase(),
        getAllTimeStatsUseCase: GetAllTimeStatisticsUseCase = GetAllTimeStatisticsUseCase(),
        getProjectedYearStatsUseCase: GetProjectedYearStatsUseCase = GetProjectedYearStatsUseCase(),
        confirmVehiclePurchaseUseCase: ConfirmVehiclePurchaseUseCase = ConfirmVehiclePurchaseUseCase(),
        getFuelUsageUseCase: GetFuelUsageUseCase = GetFuelUsageUseCase(),
        updateFuelUsageUseCase: UpdateFuelUsageUseCase = UpdateFuelUsageUseCase(),
        updateFuelUsagePartialFillStatusUseCase: UpdateFuelUsagePartialFillStatusUseCase = UpdateFuelUsagePartialFillStatusUseCase()
    ) {
        self.loadActiveVehicleUseCase = loadActiveVehicleUseCase
        self.saveVehicleUseCase = saveVehicleUseCase
        self.updateVehicleUseCase = updateVehicleUseCase
        self.updateOdometerUseCase = updateOdometerUseCase
        self.deleteVehicleUseCase = deleteVehicleUseCase
        self.saveFuelUsageUseCase = saveFuelUsageUseCase
        self.deleteFuelUsageUseCase = deleteFuelUsageUseCase
        self.resetFuelUsageUseCase = resetFuelUsageUseCase
        self.saveMaintenanceUseCase = saveMaintenanceUseCase
        self.deleteMaintenanceUseCase = deleteMaintenanceUseCase
        self.resetMaintenanceUseCase = resetMaintenanceUseCase
        self.updateVehiclePurchaseStatusUseCase = updateVehiclePurchaseStatusUseCase
        self.migrateVehiclesUseCase = migrateVehiclesUseCase
        self.getFuelUsedUseCase = getFuelUsedUseCase
        self.getFuelCostUseCase = getFuelCostUseCase
        self.getKmDrivenUseCase = getKmDrivenUseCase
        self.getAverageFuelUsageUseCase = getAverageFuelUsageUseCase
        self.getUsingMetricUseCase = getUsingMetricUseCase
        self.getCurrentMonthStatsUseCase = getCurrentMonthStatsUseCase
        self.getLastMonthStatsUseCase = getLastMonthStatsUseCase
        self.getYtdStatsUseCase = getYtdStatsUseCase
        self.getAllTimeStatsUseCase = getAllTimeStatsUseCase
        self.getProjectedYearStatsUseCase = getProjectedYearStatsUseCase
        self.confirmVehiclePurchaseUseCase = confirmVehiclePurchaseUseCase
        self.getFuelUsageUseCase = getFuelUsageUseCase
        self.updateFuelUsageUseCase = updateFuelUsageUseCase
        self.updateFuelUsagePartialFillStatusUseCase = updateFuelUsagePartialFillStatusUseCase
    }
    
    public func loadActiveVehicle(context: ModelContext) {
        do {
            // Run migration to detect partial fills in existing data
            try migrateVehiclesUseCase(context: context)
            
            let vehicle = try loadActiveVehicleUseCase(context: context)
            activeVehicleID = vehicle?.persistentModelID
            // Clear cache when vehicle is reloaded
            cachedMonthlySummaries = nil
            cachedMonthlySummariesVehicleID = nil
            cachedProjectedYearStats = nil
            cachedProjectedYearStatsVehicleID = nil
            refreshID = UUID()
            
            // Pre-calculate projected year stats to avoid scroll lag
            // This happens synchronously but is cached, so subsequent calls during scroll will be fast
            if let vehicle = vehicle {
                do {
                    let stats = try getProjectedYearStatsUseCase(context: context)
                    cachedProjectedYearStats = stats
                    cachedProjectedYearStatsVehicleID = vehicle.persistentModelID
                } catch { }
            }
        } catch { }
    }
    
    public func saveVehicle(vehicle: Vehicle, initialMileage: Int, context: ModelContext) {
        do {
            try saveVehicleUseCase(vehicle: vehicle, initialMileage: initialMileage, context: context)
            activeVehicleID = vehicle.persistentModelID
            refreshID = UUID()
        } catch { }
    }
    
    public func confirmPurchase(context: ModelContext) {
        guard let vehicle = resolvedVehicle(context: context) else { return }
        do {
            try confirmVehiclePurchaseUseCase(context: context)
            vehicle.isPurchased = true
            refreshID = UUID()
        } catch { }
    }
    
    public func updateVehicle(
        name: String,
        fuelType: FuelType?,
        purchaseDate: Date,
        manufacturingDate: Date,
        photo: Data?,
        isPurchased: Bool?,
        context: ModelContext
    ) {
        guard let vehicle = resolvedVehicle(context: context) else { return }
        
        vehicle.name = name
        vehicle.fuelType = fuelType
        vehicle.purchaseDate = purchaseDate
        vehicle.manufacturingDate = manufacturingDate
        vehicle.photo = photo
        // Always set vehicle as purchased/active
        vehicle.isPurchased = true
        
        do {
            try updateVehicleUseCase(vehicle: vehicle, context: context)
            refreshID = UUID()
        } catch { }
    }
    
    public func updateVehicle(vehicle: Vehicle, context: ModelContext) {
        do {
            try updateVehicleUseCase(vehicle: vehicle, context: context)
            refreshID = UUID()
        } catch { }
    }

    public func updateOdometer(newValue: Int, context: ModelContext) {
        guard let vehicle = resolvedVehicle(context: context) else { return }
        guard newValue > 0 else { return }

        do {
            try updateOdometerUseCase(vehicle: vehicle, newValue: newValue, context: context)
            cachedMonthlySummaries = nil
            cachedProjectedYearStats = nil
            refreshID = UUID()
        } catch { }
    }
    
    public func deleteVehicle(context: ModelContext) throws {
        try context.delete(model: Vehicle.self)
    }
    
    public func migrateVehicles(context: ModelContext) {
        do {
            try migrateVehiclesUseCase(context: context)
        } catch { }
    }
    
    public func saveFuelUsage(liters: Double, cost: Double, mileageValue: Int, context: ModelContext) {
        do {
            try saveFuelUsageUseCase(liters: liters, cost: cost, mileageValue: mileageValue, date: Date(), context: context)
            // Invalidate caches when fuel usage changes
            cachedMonthlySummaries = nil
            cachedProjectedYearStats = nil
            refreshID = UUID()
        } catch { }
    }
    
    public func deleteFuelUsage(fuelUsage: FuelUsage, context: ModelContext) {
        do {
            try deleteFuelUsageUseCase(fuelUsage: fuelUsage, context: context)
            // Invalidate caches when fuel usage changes
            cachedMonthlySummaries = nil
            cachedProjectedYearStats = nil
            refreshID = UUID()
        } catch { }
    }
    
    public func resetAllFuelUsage(context: ModelContext) {
        do {
            try resetFuelUsageUseCase(context: context)
            refreshID = UUID()
        } catch { }
    }
    
    public func fuelUsage(id: PersistentIdentifier, context: ModelContext) -> FuelUsage? {
            (try? getFuelUsageUseCase(id: id, context: context))
        }

        public func updateFuelUsage(
            id: PersistentIdentifier,
            liters: Double,
            cost: Double,
            mileageValue: Int,
            date: Date,
            context: ModelContext
        ) {
            do {
                try updateFuelUsageUseCase(id: id, liters: liters, cost: cost, mileageValue: mileageValue, date: date, context: context)
                // Invalidate caches when fuel usage changes
                cachedMonthlySummaries = nil
                cachedProjectedYearStats = nil
                refreshID = UUID()
            } catch { }
        }
    
    public func updateFuelUsagePartialFillStatus(
        id: PersistentIdentifier,
        isPartialFill: Bool,
        context: ModelContext
    ) {
        do {
            try updateFuelUsagePartialFillStatusUseCase(id: id, isPartialFill: isPartialFill, context: context)
            // Invalidate caches when fuel usage changes
            cachedMonthlySummaries = nil
            cachedProjectedYearStats = nil
            refreshID = UUID()
        } catch { }
    }
    
    public func saveMaintenance(maintenance: Maintenance, context: ModelContext) {
        do {
            try saveMaintenanceUseCase(maintenance: maintenance, context: context)
            refreshID = UUID()
        } catch { }
    }
    
    public func deleteMaintenance(maintenance: Maintenance, context: ModelContext) {
        do {
            try deleteMaintenanceUseCase(maintenance: maintenance, context: context)
            refreshID = UUID()
        } catch { }
    }
    
    public func resetAllMaintenance(context: ModelContext) {
        do {
            try resetMaintenanceUseCase(context: context)
            refreshID = UUID()
        } catch { }
    }
    
    public func vehicleStatistics(context: ModelContext) -> [VehicleStatisticsUiModel] {
        do {
            return [
                try getCurrentMonthStatsUseCase(context: context),
                try getLastMonthStatsUseCase(context: context),
                try getYtdStatsUseCase(context: context),
                try getAllTimeStatsUseCase(context: context),
                try getProjectedYearStatsUseCase(context: context)
            ]
        } catch {
            return []
        }
    }
    
    private func calculateYearStats(year: Int, context: ModelContext) -> (distance: Double, fuel: Double, cost: Double) {
        guard let vehicle = resolvedVehicle(context: context) else {
            return (0, 0, 0)
        }
        
        let calendar = Calendar.current
        
        // Calculate distance from consecutive mileage deltas within the year (more accurate than summing months)
        let yearMileages = vehicle.mileages
            .filter { calendar.component(.year, from: $0.date) == year }
            .sorted { $0.date < $1.date }
        
        var totalDistance = 0
        if yearMileages.count > 1 {
            for idx in 1..<yearMileages.count {
                totalDistance += yearMileages[idx].value - yearMileages[idx - 1].value
            }
        }
        
        // Sum fuel and cost for all months in the year
        var totalFuel = 0.0
        var totalCost = 0.0
        for month in 1...12 {
            totalFuel += getFuelUsedUseCase(forMonth: month, year: year, context: context)
            totalCost += getFuelCostUseCase(forMonth: month, year: year, context: context)
        }
        
        return (Double(totalDistance), totalFuel, totalCost)
    }
    
    private func calculateAveragePricePerLiter(vehicle: Vehicle, period: MonthlySummaryPeriod) -> Double {
        let calendar = Calendar.current
        let fuelUsages: [FuelUsage]
        
        switch period {
        case .month(let month, let year):
            let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
            let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
            fuelUsages = vehicle.fuelUsages.filter { $0.date >= monthStart && $0.date <= monthEnd }
            
        case .yearToDate(let year):
            let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let now = Date()
            let currentMonth = calendar.component(.month, from: now)
            let monthEnd = calendar.date(from: DateComponents(year: year, month: currentMonth, day: calendar.range(of: .day, in: .month, for: now)?.count ?? 28))!
            fuelUsages = vehicle.fuelUsages.filter { $0.date >= yearStart && $0.date <= monthEnd }
            
        case .year(let year):
            let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let yearEnd = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
            fuelUsages = vehicle.fuelUsages.filter { $0.date >= yearStart && $0.date <= yearEnd }
            
        case .allTime:
            fuelUsages = vehicle.fuelUsages
            
        case .projectedYear(let year):
            // For projected year, use all fuel usages from the current year to calculate average
            let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            let now = Date()
            let currentMonth = calendar.component(.month, from: now)
            let monthEnd = calendar.date(from: DateComponents(year: year, month: currentMonth, day: calendar.range(of: .day, in: .month, for: now)?.count ?? 28))!
            fuelUsages = vehicle.fuelUsages.filter { $0.date >= yearStart && $0.date <= monthEnd }
        }
        
        guard !fuelUsages.isEmpty else { return 0 }
        let totalPrice = fuelUsages.reduce(0.0) { $0 + ($1.liters > 0 ? ($1.cost / $1.liters) * $1.liters : 0) }
        let totalFuel = fuelUsages.reduce(0.0) { $0 + $1.liters }
        return totalFuel > 0 ? totalPrice / totalFuel : 0
    }
    
    public func monthlyFuelSummaries(context: ModelContext) -> [MonthlyFuelSummaryUiModel] {
        guard let vehicle = resolvedVehicle(context: context) else {
            cachedMonthlySummaries = nil
            cachedMonthlySummariesVehicleID = nil
            return []
        }
        
        // Return cached result if vehicle hasn't changed
        if let cached = cachedMonthlySummaries,
           let cachedID = cachedMonthlySummariesVehicleID,
           cachedID == vehicle.persistentModelID {
            return cached
        }
        
        do {
            let calendar = Calendar.current
            let now = Date()
            let currentYear = calendar.component(.year, from: now)
            let currentMonth = calendar.component(.month, from: now)
            var summaries: [MonthlyFuelSummaryUiModel] = []
            
            // 1. Current Month
            let currentMonthStats = try getCurrentMonthStatsUseCase(context: context)
            let currentMonthPeriod = MonthlySummaryPeriod.month(month: currentMonth, year: currentYear)
            summaries.append(
                MonthlyFuelSummaryUiModel(
                    period: currentMonthPeriod,
                    totalDistance: currentMonthStats.distanceDriven,
                    averagePricePerLiter: calculateAveragePricePerLiter(vehicle: vehicle, period: currentMonthPeriod),
                    totalFuelVolume: currentMonthStats.fuelUsed,
                    totalCost: currentMonthStats.totalCost
                )
            )
            
            // 2. Last Month
            let lastMonthStats = try getLastMonthStatsUseCase(context: context)
            let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            let lastMonth = calendar.component(.month, from: lastMonthDate)
            let lastMonthYear = calendar.component(.year, from: lastMonthDate)
            let lastMonthPeriod = MonthlySummaryPeriod.month(month: lastMonth, year: lastMonthYear)
            summaries.append(
                MonthlyFuelSummaryUiModel(
                    period: lastMonthPeriod,
                    totalDistance: lastMonthStats.distanceDriven,
                    averagePricePerLiter: calculateAveragePricePerLiter(vehicle: vehicle, period: lastMonthPeriod),
                    totalFuelVolume: lastMonthStats.fuelUsed,
                    totalCost: lastMonthStats.totalCost
                )
            )
            
            // 3. YTD (Year to Date) - total, not average
            let ytdStats = try getYtdStatsUseCase(context: context)
            let ytdPeriod = MonthlySummaryPeriod.yearToDate(year: currentYear)
            summaries.append(
                MonthlyFuelSummaryUiModel(
                    period: ytdPeriod,
                    totalDistance: ytdStats.distanceDriven,
                    averagePricePerLiter: calculateAveragePricePerLiter(vehicle: vehicle, period: ytdPeriod),
                    totalFuelVolume: ytdStats.fuelUsed,
                    totalCost: ytdStats.totalCost
                )
            )
            
            // 4. Projected Year - use cached value if available, otherwise calculate
            let projectedYearStats: VehicleStatisticsUiModel
            if let cached = cachedProjectedYearStats,
               let cachedID = cachedProjectedYearStatsVehicleID,
               cachedID == vehicle.persistentModelID {
                projectedYearStats = cached
            } else {
                // Calculate and cache
                projectedYearStats = try getProjectedYearStatsUseCase(context: context)
                cachedProjectedYearStats = projectedYearStats
                cachedProjectedYearStatsVehicleID = vehicle.persistentModelID
            }
            let projectedYearPeriod = MonthlySummaryPeriod.projectedYear(year: currentYear)
            summaries.append(
                MonthlyFuelSummaryUiModel(
                    period: projectedYearPeriod,
                    totalDistance: projectedYearStats.distanceDriven,
                    averagePricePerLiter: calculateAveragePricePerLiter(vehicle: vehicle, period: projectedYearPeriod),
                    totalFuelVolume: projectedYearStats.fuelUsed,
                    totalCost: projectedYearStats.totalCost
                )
            )
            
            // 5. Last Year (full year total)
            let lastYear = currentYear - 1
            let lastYearStats = calculateYearStats(year: lastYear, context: context)
            let lastYearPeriod = MonthlySummaryPeriod.year(year: lastYear)
            summaries.append(
                MonthlyFuelSummaryUiModel(
                    period: lastYearPeriod,
                    totalDistance: lastYearStats.distance,
                    averagePricePerLiter: calculateAveragePricePerLiter(vehicle: vehicle, period: lastYearPeriod),
                    totalFuelVolume: lastYearStats.fuel,
                    totalCost: lastYearStats.cost
                )
            )
            
            // 6. All Time
            let allTimeStats = try getAllTimeStatsUseCase(context: context)
            let allTimePeriod = MonthlySummaryPeriod.allTime
            summaries.append(
                MonthlyFuelSummaryUiModel(
                    period: allTimePeriod,
                    totalDistance: allTimeStats.distanceDriven,
                    averagePricePerLiter: calculateAveragePricePerLiter(vehicle: vehicle, period: allTimePeriod),
                    totalFuelVolume: allTimeStats.fuelUsed,
                    totalCost: allTimeStats.totalCost
                )
            )
            
            // Cache the result
            cachedMonthlySummaries = summaries
            cachedMonthlySummariesVehicleID = vehicle.persistentModelID
            
            return summaries
        } catch {
            cachedMonthlySummaries = nil
            cachedMonthlySummariesVehicleID = nil
            return []
        }
    }
    
    public func fuelUsed(forMonth month: Int, year: Int? = nil, context: ModelContext) -> Double {
        getFuelUsedUseCase(forMonth: month, year: year, context: context)
    }
    
    public func fuelCost(forMonth month: Int, year: Int? = nil, context: ModelContext) -> Double {
        getFuelCostUseCase(forMonth: month, year: year, context: context)
    }
    
    public func kmDriven(forMonth month: Int, year: Int? = nil, context: ModelContext) -> Int {
        getKmDrivenUseCase(forMonth: month, year: year, context: context)
    }
    
    public func averageFuelUsage(forMonth month: Int, year: Int? = nil, context: ModelContext) -> Double {
        getAverageFuelUsageUseCase(forMonth: month, year: year, context: context)
    }
    
    public func resolvedVehicle(context: ModelContext) -> Vehicle? {
        guard let id = activeVehicleID else { return nil }
        return context.model(for: id) as? Vehicle
    }
}
