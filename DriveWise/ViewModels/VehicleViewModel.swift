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

    func loadActiveVehicle(context: ModelContext) {
        do {
            let result = try context.fetch(FetchDescriptor<Vehicle>())
            if result.isEmpty {
                print("No vehicles found in the database.")
            } else {
                print("Fetched vehicles: \(result.count)")
                for vehicle in result {
                    print("Vehicle: \(vehicle.name), \(vehicle.licensePlate)")
                }
                activeVehicle = result.first
            }
        } catch {
            print("Error fetching vehicles: \(error.localizedDescription)")
        }
    }

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
            print("Vehicle saved successfully: \(newVehicle)")
            return true
        } catch {
            print("Error saving vehicle: \(error.localizedDescription)")
            return false
        }
    }

    func addRefueling(mileage: Int, amount: Double, cost: Double, context: ModelContext) {
        guard let vehicle = activeVehicle else { return }
        let refueling = HistoryItem(
            type: .refueling,
            dateTime: Date(),
            details: "Refueled \(amount) liters",
            cost: cost,
            mileage: mileage,
            vehicle: vehicle
        )
        vehicle.history.append(refueling)
        vehicle.mileage = mileage
        try? context.save()
    }

    func addMaintenance(details: String, cost: Double, mileage: Int?, context: ModelContext) {
        guard let vehicle = activeVehicle else { return }
        let maintenance = HistoryItem(
            type: .maintenance,
            dateTime: Date(),
            details: details,
            cost: cost,
            mileage: mileage,
            vehicle: vehicle
        )
        vehicle.history.append(maintenance)
        if let mileage = mileage {
            vehicle.mileage = mileage
        }
        try? context.save()
    }
}
