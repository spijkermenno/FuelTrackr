// MARK: - Package: Presentation

//
//  VehicleViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/04/2025.
//

import SwiftUI
import Domain


public class VehicleViewModel: ObservableObject {
    @Published public var activeVehicle: Vehicle?
    @Published public var refreshID = UUID()

    // MARK: - Dependencies (Use Cases)
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

    public var hasActiveVehicle: Bool {
        activeVehicle != nil
    }

    public init(
        loadActiveVehicleUseCase: LoadActiveVehicleUseCase,
        saveVehicleUseCase: SaveVehicleUseCase,
        updateVehicleUseCase: UpdateVehicleUseCase,
        deleteVehicleUseCase: DeleteVehicleUseCase,
        saveFuelUsageUseCase: SaveFuelUsageUseCase,
        deleteFuelUsageUseCase: DeleteFuelUsageUseCase,
        resetFuelUsageUseCase: ResetFuelUsageUseCase,
        saveMaintenanceUseCase: SaveMaintenanceUseCase,
        deleteMaintenanceUseCase: DeleteMaintenanceUseCase,
        resetMaintenanceUseCase: ResetMaintenanceUseCase,
        updateVehiclePurchaseStatusUseCase: UpdateVehiclePurchaseStatusUseCase,
        migrateVehiclesUseCase: MigrateVehiclesUseCase,
        getFuelUsedUseCase: GetFuelUsedUseCase,
        getFuelCostUseCase: GetFuelCostUseCase,
        getKmDrivenUseCase: GetKmDrivenUseCase,
        getAverageFuelUsageUseCase: GetAverageFuelUsageUseCase,
        getUsingMetricUseCase: GetUsingMetricUseCase
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
    }

    // MARK: - Vehicle Operations

    public var isUsingMetric: Bool {
        getUsingMetricUseCase()
    }

    public func loadActiveVehicle() {
        do {
            activeVehicle = try loadActiveVehicleUseCase()
            refreshID = UUID()
        } catch {
            print("Error loading active vehicle: \(error.localizedDescription)")
        }
    }

    public func saveVehicle(vehicle: Vehicle, initialMileage: Int) {
        do {
            try saveVehicleUseCase(vehicle: vehicle, initialMileage: initialMileage)
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
        photo: Data?
    ) {
        guard let vehicle = activeVehicle else {
            print("No active vehicle to update.")
            return
        }

        vehicle.name = name
        vehicle.licensePlate = licensePlate
        vehicle.purchaseDate = purchaseDate
        vehicle.manufacturingDate = manufacturingDate
        vehicle.photo = photo

        do {
            try updateVehicleUseCase(vehicle: vehicle)
            refreshID = UUID()

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let purchaseDay = calendar.startOfDay(for: purchaseDate)

            if purchaseDay > today {
                let daysUntilPurchase = calendar.dateComponents([.day], from: today, to: purchaseDay).day ?? 0

//                NotificationManager.shared.scheduleNotification(
//                    title: NSLocalizedString("notification_purchase_date_passed_title", comment: ""),
//                    body: NSLocalizedString("notification_purchase_date_passed_description", comment: ""),
//                    inDays: daysUntilPurchase,
//                    atHour: 18,
//                    atMinute: 0
//                )
            } else {
                try updateVehiclePurchaseStatusUseCase(isPurchased: true)
            }
        } catch {
            print("Error updating vehicle: \(error.localizedDescription)")
        }
    }

    public func updateVehicle(vehicle: Vehicle) {
        do {
            try updateVehicleUseCase(vehicle: vehicle)
            refreshID = UUID()
        } catch {
            print("Error updating vehicle: \(error.localizedDescription)")
        }
    }

    public func deleteActiveVehicle() {
        do {
            try deleteVehicleUseCase()
            activeVehicle = nil
            refreshID = UUID()
        } catch {
            print("Error deleting vehicle: \(error.localizedDescription)")
        }
    }

    public func updateVehiclePurchaseStatus(isPurchased: Bool) {
        do {
            try updateVehiclePurchaseStatusUseCase(isPurchased: isPurchased)
            refreshID = UUID()
        } catch {
            print("Error updating purchase status: \(error.localizedDescription)")
        }
    }

    public func migrateVehicles() {
        do {
            try migrateVehiclesUseCase()
        } catch {
            print("Error migrating vehicles: \(error.localizedDescription)")
        }
    }

    // MARK: - Fuel Usage

    public func saveFuelUsage(liters: Double, cost: Double, mileageValue: Int) {
        do {
            try saveFuelUsageUseCase(liters: liters, cost: cost, mileageValue: mileageValue)
            refreshID = UUID()
        } catch {
            print("Error saving fuel usage: \(error.localizedDescription)")
        }
    }

    public func deleteFuelUsage(fuelUsage: FuelUsage) {
        do {
            try deleteFuelUsageUseCase(fuelUsage: fuelUsage)
            refreshID = UUID()
        } catch {
            print("Error deleting fuel usage: \(error.localizedDescription)")
        }
    }

    public func resetAllFuelUsage() {
        do {
            try resetFuelUsageUseCase()
            refreshID = UUID()
        } catch {
            print("Error resetting fuel usage: \(error.localizedDescription)")
        }
    }

    // MARK: - Maintenance

    public func saveMaintenance(maintenance: Maintenance) {
        do {
            try saveMaintenanceUseCase(maintenance: maintenance)
            refreshID = UUID()
        } catch {
            print("Error saving maintenance: \(error.localizedDescription)")
        }
    }

    public func deleteMaintenance(maintenance: Maintenance) {
        do {
            try deleteMaintenanceUseCase(maintenance: maintenance)
            refreshID = UUID()
        } catch {
            print("Error deleting maintenance: \(error.localizedDescription)")
        }
    }

    public func resetAllMaintenance() {
        do {
            try resetMaintenanceUseCase()
            refreshID = UUID()
        } catch {
            print("Error resetting maintenance: \(error.localizedDescription)")
        }
    }

    // MARK: - Monthly Recap

    public func fuelUsed(forMonth month: Int, year: Int? = nil) -> Double {
        getFuelUsedUseCase(forMonth: month, year: year)
    }

    public func fuelCost(forMonth month: Int, year: Int? = nil) -> Double {
        getFuelCostUseCase(forMonth: month, year: year)
    }

    public func kmDriven(forMonth month: Int, year: Int? = nil) -> Int {
        getKmDrivenUseCase(forMonth: month, year: year)
    }

    public func averageFuelUsage(forMonth month: Int, year: Int? = nil) -> Double {
        getAverageFuelUsageUseCase(forMonth: month, year: year)
    }
}
