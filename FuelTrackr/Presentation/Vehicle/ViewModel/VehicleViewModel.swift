// MARK: - Package: Presentation
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
    @Published public var activeVehicle: Vehicle?
    @Published public var refreshID = UUID()

    // ───── Core vehicle use-cases
    private let loadActiveVehicleUseCase: LoadActiveVehicleUseCase
    private let saveVehicleUseCase: SaveVehicleUseCase
    private let updateVehicleUseCase: UpdateVehicleUseCase
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

    // ───── Statistics use-cases
    private let getCurrentMonthStatsUseCase: GetCurrentMonthStatisticsUseCase
    private let getLastMonthStatsUseCase: GetLastMonthStatisticsUseCase
    private let getYtdStatsUseCase: GetYearToDateStatisticsUseCase
    private let getAllTimeStatsUseCase: GetAllTimeStatisticsUseCase
    private let getProjectedYearStatsUseCase: GetProjectedYearStatsUseCase

    // ───── Purchase confirmation use-case
    private let confirmVehiclePurchaseUseCase: ConfirmVehiclePurchaseUseCase
    
    public var hasActiveVehicle: Bool { activeVehicle != nil }

    // ───── Init with DI-ready defaults
    public init(
        loadActiveVehicleUseCase: LoadActiveVehicleUseCase = LoadActiveVehicleUseCase(),
        saveVehicleUseCase: SaveVehicleUseCase = SaveVehicleUseCase(),
        updateVehicleUseCase: UpdateVehicleUseCase = UpdateVehicleUseCase(),
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
        confirmVehiclePurchaseUseCase: ConfirmVehiclePurchaseUseCase = ConfirmVehiclePurchaseUseCase(),
        getProjectedYearStatsUseCase: GetProjectedYearStatsUseCase = GetProjectedYearStatsUseCase()
    ) {
        self.loadActiveVehicleUseCase = loadActiveVehicleUseCase
        self.saveVehicleUseCase = saveVehicleUseCase
        self.updateVehicleUseCase = updateVehicleUseCase
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
    }

    // ───── Public helpers
    public var isUsingMetric: Bool { getUsingMetricUseCase() }

    // ───── Confirm purchase
       public func confirmPurchase(context: ModelContext) {
           do {
               try confirmVehiclePurchaseUseCase(context: context)
               activeVehicle?.isPurchased = true
               refreshID = UUID()
           } catch {
               print("Error confirming purchase: \(error.localizedDescription)")
           }
       }
    
    public func updateVehiclePurchaseStatus(
        isPurchased: Bool,
        context: ModelContext
    ) {
        do {
            try updateVehiclePurchaseStatusUseCase(
                isPurchased: isPurchased,
                context: context
            )
            refreshID = UUID()
        } catch {
            print("Error updating purchase status: \(error.localizedDescription)")
        }
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
            print("Error generating statistics: \(error.localizedDescription)")
            return []
        }
    }

    // ───── Vehicle CRUD
    public func loadActiveVehicle(context: ModelContext) {
        do {
            let fetched = try loadActiveVehicleUseCase(context: context)

            if fetched != activeVehicle {
                activeVehicle = fetched
                refreshID = UUID()
            }
        } catch {
            Swift.print("Error loading active vehicle: \(error.localizedDescription)")
        }
    }

    public func saveVehicle(
        vehicle: Vehicle,
        initialMileage: Int,
        context: ModelContext
    ) {
        do {
            try saveVehicleUseCase(
                vehicle: vehicle,
                initialMileage: initialMileage,
                context: context
            )
            activeVehicle = vehicle
            refreshID = UUID()
        } catch {
            print("Error saving vehicle: \(error.localizedDescription)")
        }
    }

    public func updateVehicle(
        name: String,
        licensePlate: String,
        purchaseDate: Date,
        manufacturingDate: Date,
        photo: Data?,
        context: ModelContext
    ) {
        guard let vehicle = activeVehicle else { return }

        vehicle.name = name
        vehicle.licensePlate = licensePlate
        vehicle.purchaseDate = purchaseDate
        vehicle.manufacturingDate = manufacturingDate
        vehicle.photo = photo

        do {
            try updateVehicleUseCase(vehicle: vehicle, context: context)
            refreshID = UUID()

            let cal = Calendar.current
            let today = cal.startOfDay(for: Date())
            let purchaseDay = cal.startOfDay(for: purchaseDate)

            if purchaseDay <= today {
                try updateVehiclePurchaseStatusUseCase(
                    isPurchased: true,
                    context: context
                )
            }
        } catch {
            print("Error updating vehicle: \(error.localizedDescription)")
        }
    }

    public func updateVehicle(
        vehicle: Vehicle,
        context: ModelContext
    ) {
        do {
            try updateVehicleUseCase(vehicle: vehicle, context: context)
            refreshID = UUID()
        } catch {
            print("Error updating vehicle: \(error.localizedDescription)")
        }
    }

    public func deleteActiveVehicle(context: ModelContext) {
        do {
            try deleteVehicleUseCase(context: context)
            activeVehicle = nil
            refreshID = UUID()
        } catch {
            print("Error deleting vehicle: \(error.localizedDescription)")
        }
    }

    public func migrateVehicles(context: ModelContext) {
        do {
            try migrateVehiclesUseCase(context: context)
        } catch {
            print("Error migrating vehicles: \(error.localizedDescription)")
        }
    }

    // ───── Fuel
    public func saveFuelUsage(
        liters: Double,
        cost: Double,
        mileageValue: Int,
        context: ModelContext
    ) {
        do {
            try saveFuelUsageUseCase(
                liters: liters,
                cost: cost,
                mileageValue: mileageValue,
                context: context
            )
            refreshID = UUID()
        } catch {
            print("Error saving fuel usage: \(error.localizedDescription)")
        }
    }

    public func deleteFuelUsage(
        fuelUsage: FuelUsage,
        context: ModelContext
    ) {
        do {
            try deleteFuelUsageUseCase(
                fuelUsage: fuelUsage,
                context: context
            )
            refreshID = UUID()
        } catch {
            print("Error deleting fuel usage: \(error.localizedDescription)")
        }
    }

    public func resetAllFuelUsage(context: ModelContext) {
        do {
            try resetFuelUsageUseCase(context: context)
            refreshID = UUID()
        } catch {
            print("Error resetting fuel usage: \(error.localizedDescription)")
        }
    }

    // ───── Maintenance
    public func saveMaintenance(
        maintenance: Maintenance,
        context: ModelContext
    ) {
        do {
            try saveMaintenanceUseCase(
                maintenance: maintenance,
                context: context
            )
            refreshID = UUID()
        } catch {
            print("Error saving maintenance: \(error.localizedDescription)")
        }
    }

    public func deleteMaintenance(
        maintenance: Maintenance,
        context: ModelContext
    ) {
        do {
            try deleteMaintenanceUseCase(
                maintenance: maintenance,
                context: context
            )
            refreshID = UUID()
        } catch {
            print("Error deleting maintenance: \(error.localizedDescription)")
        }
    }

    public func resetAllMaintenance(context: ModelContext) {
        do {
            try resetMaintenanceUseCase(context: context)
            refreshID = UUID()
        } catch {
            print("Error resetting maintenance: \(error.localizedDescription)")
        }
    }

    // ───── Monthly helpers
    public func fuelUsed(
        forMonth month: Int,
        year: Int? = nil,
        context: ModelContext
    ) -> Double {
        getFuelUsedUseCase(forMonth: month, year: year, context: context)
    }

    public func fuelCost(
        forMonth month: Int,
        year: Int? = nil,
        context: ModelContext
    ) -> Double {
        getFuelCostUseCase(forMonth: month, year: year, context: context)
    }

    public func kmDriven(
        forMonth month: Int,
        year: Int? = nil,
        context: ModelContext
    ) -> Int {
        getKmDrivenUseCase(forMonth: month, year: year, context: context)
    }

    public func averageFuelUsage(
        forMonth month: Int,
        year: Int? = nil,
        context: ModelContext
    ) -> Double {
        getAverageFuelUsageUseCase(forMonth: month, year: year, context: context)
    }
}
