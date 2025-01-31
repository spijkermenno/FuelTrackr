//
//  VehicleViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData
import UIKit

class VehicleViewModel: ObservableObject {
    @Published var activeVehicle: Vehicle?
    @Published var fuelHistory: [FuelUsage] = []
    @Published var maintenanceHistory: [Maintenance] = []
    
    func loadActiveVehicle(context: ModelContext) {
        do {
            let result = try context.fetch(FetchDescriptor<Vehicle>())
            if let existingVehicle = result.first {
                activeVehicle = existingVehicle
                updateFuelHistory()
                updateMaintenanceHistory()
            }
        } catch {
            print("Error fetching vehicles: \(error.localizedDescription)")
        }
    }
    
    func updateVehicle(
        context: ModelContext,
        name: String,
        licensePlate: String,
        purchaseDate: Date,
        manufacturingDate: Date,
        mileage: Int,
        photo: Data?,
        isPurchased: Bool
    ) {
        guard let vehicle = activeVehicle else { return }
        
        vehicle.name = name
        vehicle.licensePlate = licensePlate
        vehicle.purchaseDate = purchaseDate
        vehicle.manufacturingDate = manufacturingDate
        vehicle.mileage = mileage
        vehicle.photo = photo
        vehicle.isPurchased = isPurchased
        
        saveContext(context: context)
    }

    func saveVehicle(
        context: ModelContext,
        vehicleName: String,
        licensePlate: String,
        purchaseDate: Date,
        manufacturingDate: Date,
        mileage: Int,
        image: UIImage?
    ) -> Bool {
        let newVehicle = Vehicle(
            name: vehicleName,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            mileage: mileage,
            photo: image?.jpegData(compressionQuality: 0.8)
        )
        context.insert(newVehicle)
        do {
            try context.save()
            activeVehicle = newVehicle
            fuelHistory = []
            maintenanceHistory = []
            return true
        } catch {
            print("Error saving vehicle: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteActiveVehicle(context: ModelContext) {
        guard let vehicle = activeVehicle else {
            return
        }
        
        context.delete(vehicle)
        
        do {
            try context.save()
            activeVehicle = nil
        } catch {
            print("Error deleting active vehicle: \(error.localizedDescription)")
        }
    }
    
    func saveFuelUsage(context: ModelContext, liters: Double, cost: Double, mileage: Int) -> Bool {
        guard let vehicle = activeVehicle else {
            return false
        }
        
        if mileage <= vehicle.mileage {
            return false
        }
        
        let newFuelUsage = FuelUsage(
            liters: liters,
            cost: cost,
            mileage: mileage,
            date: Date(),
            vehicle: vehicle
        )
        
        vehicle.fuelUsages.append(newFuelUsage)
        vehicle.mileage = mileage
        
        return saveContext(context: context)
    }
    
    func updateFuelHistory() {
        guard let vehicle = activeVehicle else {
            fuelHistory = []
            return
        }
        fuelHistory = vehicle.fuelUsages.sorted { $0.date > $1.date }
    }
    
    func deleteFuelUsage(context: ModelContext, fuelUsage: FuelUsage) {
        guard let vehicle = activeVehicle else {
            print("No active vehicle to delete fuel usage from.")
            return
        }
        
        if let index = vehicle.fuelUsages.firstIndex(of: fuelUsage) {
            vehicle.fuelUsages.remove(at: index)
        }
        
        context.delete(fuelUsage)
        
        saveContext(context: context)
    }
    
    func saveMaintenance(
        context: ModelContext,
        maintenanceType: MaintenanceType,
        cost: Double,
        date: Date,
        mileage: Int,
        notes: String?
    ) -> Bool {
        guard let vehicle = activeVehicle else {
            return false
        }
        
        let newMaintenance = Maintenance(
            type: maintenanceType,
            cost: cost,
            date: date,
            mileage: mileage,
            notes: notes,
            vehicle: vehicle
        )
        
        vehicle.maintenances.append(newMaintenance)
        
        // Only update mileage if it's higher than the current mileage
        if mileage > vehicle.mileage {
            vehicle.mileage = mileage
        }
        
        return saveContext(context: context)
    }
    
    func updateMaintenanceHistory() {
        guard let vehicle = activeVehicle else {
            maintenanceHistory = []
            return
        }
        maintenanceHistory = vehicle.maintenances.sorted(by: { $0.date > $1.date })
    }
    
    func deleteMaintenance(context: ModelContext, maintenance: Maintenance) {
        guard let vehicle = activeVehicle else {
            return
        }
        
        if let index = vehicle.maintenances.firstIndex(of: maintenance) {
            vehicle.maintenances.remove(at: index)
        }
        
        context.delete(maintenance)
        
        saveContext(context: context)
    }
    
    func resetAllMaintenance(context: ModelContext) -> Bool {
        activeVehicle?.maintenances.removeAll()
        return saveContext(context: context)
    }

    func resetAllFuelUsage(context: ModelContext) -> Bool {
        activeVehicle?.fuelUsages.removeAll()
        return saveContext(context: context)
    }

    private func saveContext(context: ModelContext) -> Bool {
        do {
            try context.save()
            print("Data saved successfully.")
            return true
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
            return false
        }
    }
    
    func updateVehiclePurchaseStatus(isPurchased: Bool, context: ModelContext) {
        activeVehicle?.isPurchased = isPurchased
        saveContext(context: context)
    }
    
    // MARK: Migrations
    
    func migrateVehicles(context: ModelContext) {
        let allVehicles = try? context.fetch(FetchDescriptor<Vehicle>())
        allVehicles?.forEach { vehicle in
            if vehicle.isPurchased == nil {
                print(vehicle)
                vehicle.isPurchased = vehicle.purchaseDate <= Date()
            }
        }
        try? context.save()
    }
}
