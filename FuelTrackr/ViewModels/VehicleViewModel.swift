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
    
    func loadActiveVehicle(context: ModelContext) {
        do {
            let result = try context.fetch(FetchDescriptor<Vehicle>())
            if let existingVehicle = result.first {
                activeVehicle = existingVehicle
                
                print(activeVehicle?.mileages)
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
        photo: Data?,
        isPurchased: Bool
    ) {
        guard let vehicle = activeVehicle else { return }

        vehicle.name = name
        vehicle.licensePlate = licensePlate
        vehicle.purchaseDate = purchaseDate
        vehicle.manufacturingDate = manufacturingDate
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
        initialMileage: Int,
        image: UIImage?
    ) -> Bool {
        let newVehicle = Vehicle(
            name: vehicleName,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            photo: image?.jpegData(compressionQuality: 0.8)
        )

        // Create the initial mileage entry
        let initialMileageEntry = Mileage(value: initialMileage, date: Date(), vehicle: newVehicle)

        // Explicitly insert the mileage entry into the context
        context.insert(initialMileageEntry)

        // Ensure the relationship is established before inserting the vehicle
        newVehicle.mileages.append(initialMileageEntry)

        // Insert the vehicle into the context after all properties are set
        context.insert(newVehicle)

        do {
            print("Before Save: \(newVehicle.mileages)")
            try context.save()
            print("After Save: \(activeVehicle?.mileages ?? [])")

            activeVehicle = newVehicle

            return true
        } catch {
            print("Error saving vehicle: \(error.localizedDescription)")
            return false
        }
    }

    func deleteActiveVehicle(context: ModelContext) {
        print("Deleting vehicle started")

        guard let vehicle = activeVehicle else {
            print("No active vehicle to delete")
            return
        }

        print("Vehicle found: \(vehicle)")

        // Remove relationships manually (if needed)
        vehicle.mileages.forEach { context.delete($0) }
        vehicle.fuelUsages.forEach { context.delete($0) }
        vehicle.maintenances.forEach { context.delete($0) }

        print("Deleted related records")

        // Nullify the reference before deletion to prevent EXC_BAD_ACCESS
        activeVehicle = nil

        print("Deleting vehicle...")
        context.delete(vehicle)

        do {
            print("Saving context...")
            try context.save()
            print("Vehicle successfully deleted")
        } catch {
            print("Error deleting active vehicle: \(error.localizedDescription)")
        }
    }

    func saveFuelUsage(context: ModelContext, liters: Double, cost: Double, mileageValue: Int) -> Bool {
        guard let vehicle = activeVehicle else { return false }
        
        let mileage = getOrCreateMileage(context: context, mileageValue: mileageValue)
        
        let newFuelUsage = FuelUsage(
            liters: liters,
            cost: cost,
            date: Date(),
            mileage: mileage,
            vehicle: vehicle
        )

        vehicle.fuelUsages.append(newFuelUsage)
        
        return saveContext(context: context)
    }

    func saveMaintenance(
        context: ModelContext,
        maintenanceType: MaintenanceType,
        cost: Double,
        date: Date,
        mileageValue: Int,
        notes: String?
    ) -> Bool {
        guard let vehicle = activeVehicle else { return false }
        
        let mileage = getOrCreateMileage(context: context, mileageValue: mileageValue)

        let newMaintenance = Maintenance(
            type: maintenanceType,
            cost: cost,
            date: date,
            mileage: mileage,
            notes: notes,
            vehicle: vehicle
        )

        vehicle.maintenances.append(newMaintenance)

        return saveContext(context: context)
    }

    private func getOrCreateMileage(context: ModelContext, mileageValue: Int) -> Mileage {
        guard let vehicle = activeVehicle else { fatalError("No active vehicle") }
        
        if let existingMileage = vehicle.mileages.first(where: { $0.value == mileageValue }) {
            return existingMileage
        }
        
        let newMileage = Mileage(value: mileageValue, date: Date(), vehicle: vehicle)
        vehicle.mileages.append(newMileage)
        return newMileage
    }

    func deleteFuelUsage(context: ModelContext, fuelUsage: FuelUsage) {
        guard let vehicle = activeVehicle else { return }
        
        if let index = vehicle.fuelUsages.firstIndex(of: fuelUsage) {
            vehicle.fuelUsages.remove(at: index)
        }

        context.delete(fuelUsage)
        
        saveContext(context: context)
    }

    func deleteMaintenance(context: ModelContext, maintenance: Maintenance) {
        guard let vehicle = activeVehicle else { return }
        
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

    func migrateVehicles(context: ModelContext) {
        let allVehicles = try? context.fetch(FetchDescriptor<Vehicle>())
        allVehicles?.forEach { vehicle in
            if vehicle.isPurchased == nil {
                vehicle.isPurchased = vehicle.purchaseDate <= Date()
            }
        }
        try? context.save()
    }
}
