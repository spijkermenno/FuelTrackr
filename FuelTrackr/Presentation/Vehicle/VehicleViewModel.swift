//
//  VehicleViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/04/2025.
//

import SwiftUI

class VehicleViewModel: ObservableObject {
    @Published var activeVehicle: Vehicle?
    @Published var refreshID = UUID()

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

    var hasActiveVehicle: Bool {
        activeVehicle != nil
    }

    init(
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

    var isUsingMetric: Bool {
        getUsingMetricUseCase.execute()
    }
    
    func loadActiveVehicle() {
        do {
            activeVehicle = try loadActiveVehicleUseCase.execute()
            refreshID = UUID()
        } catch {
            print("Error loading active vehicle: \(error.localizedDescription)")
        }
    }

    func saveVehicle(vehicle: Vehicle, initialMileage: Int) {
        do {
            try saveVehicleUseCase.execute(vehicle: vehicle, initialMileage: initialMileage)
            activeVehicle = vehicle
            refreshID = UUID()
        } catch {
            print("Error saving vehicle: \(error.localizedDescription)")
        }
    }
    
    func updateVehicle(
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
                try updateVehicleUseCase.execute(vehicle: vehicle)
                refreshID = UUID()

                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let purchaseDay = calendar.startOfDay(for: purchaseDate)

                if purchaseDay > today {
                    let daysUntilPurchase = calendar.dateComponents([.day], from: today, to: purchaseDay).day ?? 0
                    
                    NotificationManager.shared.scheduleNotification(
                        title: NSLocalizedString("notification_purchase_date_passed_title", comment: ""),
                        body: NSLocalizedString("notification_purchase_date_passed_description", comment: ""),
                        inDays: daysUntilPurchase,
                        atHour: 18,
                        atMinute: 0
                    )
                } else {
                    try updateVehiclePurchaseStatusUseCase.execute(isPurchased: true)
                }
            } catch {
                print("Error updating vehicle: \(error.localizedDescription)")
            }
        }

    func updateVehicle(vehicle: Vehicle) {
        do {
            try updateVehicleUseCase.execute(vehicle: vehicle)
            refreshID = UUID()
        } catch {
            print("Error updating vehicle: \(error.localizedDescription)")
        }
    }

    func deleteActiveVehicle() {
        do {
            try deleteVehicleUseCase.execute()
            activeVehicle = nil
            refreshID = UUID()
        } catch {
            print("Error deleting vehicle: \(error.localizedDescription)")
        }
    }

    func updateVehiclePurchaseStatus(isPurchased: Bool) {
        do {
            try updateVehiclePurchaseStatusUseCase.execute(isPurchased: isPurchased)
            refreshID = UUID()
        } catch {
            print("Error updating purchase status: \(error.localizedDescription)")
        }
    }

    func migrateVehicles() {
        do {
            try migrateVehiclesUseCase.execute()
        } catch {
            print("Error migrating vehicles: \(error.localizedDescription)")
        }
    }

    // MARK: - Fuel Usage

    func saveFuelUsage(liters: Double, cost: Double, mileageValue: Int) {
        do {
            try saveFuelUsageUseCase.execute(liters: liters, cost: cost, mileageValue: mileageValue)
            refreshID = UUID()
        } catch {
            print("Error saving fuel usage: \(error.localizedDescription)")
        }
    }

    func deleteFuelUsage(fuelUsage: FuelUsage) {
        do {
            try deleteFuelUsageUseCase.execute(fuelUsage: fuelUsage)
            refreshID = UUID()
        } catch {
            print("Error deleting fuel usage: \(error.localizedDescription)")
        }
    }

    func resetAllFuelUsage() {
        do {
            try resetFuelUsageUseCase.execute()
            refreshID = UUID()
        } catch {
            print("Error resetting fuel usage: \(error.localizedDescription)")
        }
    }

    // MARK: - Maintenance

    func saveMaintenance(maintenance: Maintenance) {
        do {
            try saveMaintenanceUseCase.execute(maintenance: maintenance)
            refreshID = UUID()
        } catch {
            print("Error saving maintenance: \(error.localizedDescription)")
        }
    }

    func deleteMaintenance(maintenance: Maintenance) {
        do {
            try deleteMaintenanceUseCase.execute(maintenance: maintenance)
            refreshID = UUID()
        } catch {
            print("Error deleting maintenance: \(error.localizedDescription)")
        }
    }

    func resetAllMaintenance() {
        do {
            try resetMaintenanceUseCase.execute()
            refreshID = UUID()
        } catch {
            print("Error resetting maintenance: \(error.localizedDescription)")
        }
    }

    // MARK: - Monthly Recap

    func fuelUsed(forMonth month: Int, year: Int? = nil) -> Double {
        getFuelUsedUseCase.execute(forMonth: month, year: year)
    }

    func fuelCost(forMonth month: Int, year: Int? = nil) -> Double {
        getFuelCostUseCase.execute(forMonth: month, year: year)
    }

    func kmDriven(forMonth month: Int, year: Int? = nil) -> Int {
        getKmDrivenUseCase.execute(forMonth: month, year: year)
    }

    func averageFuelUsage(forMonth month: Int, year: Int? = nil) -> Double {
        getAverageFuelUsageUseCase.execute(forMonth: month, year: year)
    }
}
