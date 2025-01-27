//
//  VehicleViewModel.swift
//  DriveWise
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

    // Load the active vehicle from the database
    func loadActiveVehicle(context: ModelContext) {
        do {
            let result = try context.fetch(FetchDescriptor<Vehicle>())
            if result.isEmpty {
                print("No vehicles found in the database.")
            } else {
                activeVehicle = result.first
                updateFuelHistory()
            }
        } catch {
            print("Error fetching vehicles: \(error.localizedDescription)")
        }
    }

    // Save a new vehicle
    func saveVehicle(context: ModelContext, vehicleName: String, licensePlate: String, purchaseDate: Date, manufacturingDate: Date, mileage: Int, image: UIImage?) -> Bool {
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
            fuelHistory = [] // Reset fuel history for the new vehicle
            print("Vehicle saved successfully: \(newVehicle)")
            return true
        } catch {
            print("Error saving vehicle: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteActiveVehicle(context: ModelContext) {
            guard let vehicle = activeVehicle else {
                print("No active vehicle to delete.")
                return
            }

            context.delete(vehicle)

            do {
                try context.save()
                print("Active vehicle deleted successfully.")
                activeVehicle = nil // Reset active vehicle
            } catch {
                print("Error deleting active vehicle: \(error.localizedDescription)")
            }
        }

    // Save fuel usage for the active vehicle
    func saveFuelUsage(context: ModelContext, liters: Double, cost: Double, mileage: Int) -> Bool {
        guard let vehicle = activeVehicle else {
            print("No active vehicle selected to save fuel usage.")
            return false
        }

        // Check if the mileage is valid
        if mileage <= vehicle.mileage {
            print("Error: New mileage must be greater than the current mileage.")
            return false
        }

        // Create a new fuel usage entry
        let newFuelUsage = FuelUsage(
            liters: liters,
            cost: cost,
            mileage: mileage,
            date: Date(),
            vehicle: vehicle
        )

        // Add the fuel usage entry to the vehicle and update its mileage
        vehicle.fuelUsages.append(newFuelUsage)
        vehicle.mileage = mileage // Update the vehicle's mileage

        do {
            try context.save()
            updateFuelHistory()
            print("Fuel usage saved successfully: \(newFuelUsage)")
            return true
        } catch {
            print("Error saving fuel usage: \(error.localizedDescription)")
            return false
        }
    }

    // Fetch fuel history for the active vehicle
    func updateFuelHistory() {
        guard let vehicle = activeVehicle else {
            fuelHistory = []
            return
        }
        fuelHistory = vehicle.fuelUsages.sorted { $0.date > $1.date }
    }
    
    func saveMaintenance(
        context: ModelContext,
        maintenanceType: MaintenanceType,
        cost: Double,
        date: Date,
        notes: String?
    ) -> Bool {
        guard let vehicle = activeVehicle else {
            print("No active vehicle selected to save maintenance.")
            return false
        }

        // Create a new maintenance entry
        let newMaintenance = Maintenance(
            type: maintenanceType,
            cost: cost,
            date: date,
            notes: notes,
            vehicle: vehicle
        )

        // Add the maintenance entry to the vehicle
        vehicle.maintenances.append(newMaintenance)

        do {
            try context.save()
            updateMaintenanceHistory() // Refresh maintenance history
            print("Maintenance saved successfully: \(newMaintenance)")
            return true
        } catch {
            print("Error saving maintenance: \(error.localizedDescription)")
            return false
        }
    }

    func updateMaintenanceHistory() {
        guard let vehicle = activeVehicle else {
            maintenanceHistory = []
            return
        }
        maintenanceHistory = vehicle.maintenances.sorted(by: { $0.date > $1.date })
    }
}
