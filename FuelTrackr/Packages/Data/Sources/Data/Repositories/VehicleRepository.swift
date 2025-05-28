// MARK: - Package: Data
//
//  VehicleRepository.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftData
import Foundation
import Domain

public class VehicleRepository: VehicleRepositoryProtocol {
    public init() {}
    
    // MARK: - Vehicle

    public func loadActiveVehicle(context: ModelContext) throws -> Vehicle? {
        let vehicles = try context.fetch(FetchDescriptor<Vehicle>())
        if let vehicle = vehicles.first {
            print("--- Active Vehicle Info ---")
            print("Name: \(vehicle.name)")
            print("License Plate: \(vehicle.licensePlate)")
            print("Purchase Date: \(vehicle.purchaseDate)")
            print("Manufacturing Date: \(vehicle.manufacturingDate)")
            print("Is Purchased: \(vehicle.isPurchased.map { String($0) } ?? "nil")")
            print("Photo size: \(vehicle.photo?.count ?? 0) bytes")
            print("Mileages: \(vehicle.mileages.map { $0.value })")
            print("Fuel Usages: \(vehicle.fuelUsages.map { "Liters: \($0.liters), Cost: \($0.cost), Date: \($0.date)" })")
            print("Maintenances: \(vehicle.maintenances.map { "\($0.type.rawValue), Cost: \($0.cost), Date: \($0.date)" })")
            print("--------------------------")
        } else {
            print("No active vehicle found.")
        }

        return vehicles.first
    }

    public func refreshActiveVehicle(context: ModelContext) throws -> Vehicle? {
        try loadActiveVehicle(context: context)
    }

    public func saveVehicle(vehicle: Vehicle, initialMileage: Int, context: ModelContext) throws {
        let mileage = Mileage(value: initialMileage, date: Date(), vehicle: vehicle)
        vehicle.mileages.append(mileage)
        context.insert(mileage)
        context.insert(vehicle)
        try context.save()
    }

    public func updateVehicle(vehicle: Vehicle, context: ModelContext) throws {
        try context.save()
    }

    public func deleteVehicle(context: ModelContext) throws {
        let vehicles = try context.fetch(FetchDescriptor<Vehicle>())
        for vehicle in vehicles {
            context.delete(vehicle)
        }
        try context.save()
    }

    public func updateVehiclePurchaseStatus(isPurchased: Bool, context: ModelContext) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        vehicle.isPurchased = isPurchased
        try context.save()
    }

    public func migrateVehicles(context: ModelContext) throws {
        let vehicles = try context.fetch(FetchDescriptor<Vehicle>())
        for vehicle in vehicles {
            if vehicle.isPurchased == nil {
                vehicle.isPurchased = vehicle.purchaseDate <= Date()
            }
        }
        try context.save()
    }

    // MARK: - Fuel Usage

    public func saveFuelUsage(liters: Double, cost: Double, mileageValue: Int, context: ModelContext) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }

        let mileage = getOrCreateMileage(vehicle: vehicle, mileageValue: mileageValue, context: context)
        let fuelUsage = FuelUsage(liters: liters, cost: cost, date: Date(), mileage: mileage, vehicle: vehicle)
        vehicle.fuelUsages.append(fuelUsage)

        try context.save()
    }

    public func deleteFuelUsage(fuelUsage: FuelUsage, context: ModelContext) throws {
        context.delete(fuelUsage)
        try context.save()
    }

    public func resetFuelUsage(context: ModelContext) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        vehicle.fuelUsages.removeAll()
        try context.save()
    }

    public func getFuelUsed(forMonth month: Int, year: Int?, context: ModelContext) -> Double {
        guard let vehicle = try? loadActiveVehicle(context: context),
              let range = dateRange(forMonth: month, year: year) else { return 0 }

        let usages = vehicle.fuelUsages.filter { $0.date >= range.start && $0.date <= range.end }
        return usages.reduce(0) { $0 + $1.liters }
    }

    public func getFuelCost(forMonth month: Int, year: Int?, context: ModelContext) -> Double {
        guard let vehicle = try? loadActiveVehicle(context: context),
              let range = dateRange(forMonth: month, year: year) else { return 0 }

        let usages = vehicle.fuelUsages.filter { $0.date >= range.start && $0.date <= range.end }
        return usages.reduce(0) { $0 + $1.cost }
    }

    public func getKmDriven(forMonth month: Int, year: Int?, context: ModelContext) -> Int {
        guard let vehicle = try? loadActiveVehicle(context: context),
              let range = dateRange(forMonth: month, year: year) else { return 0 }

        let mileages = vehicle.mileages
            .filter { $0.date >= range.start && $0.date <= range.end }
            .sorted(by: { $0.date < $1.date })

        guard let first = mileages.first, let last = mileages.last else { return 0 }
        return last.value - first.value
    }

    public func getAverageFuelUsage(forMonth month: Int, year: Int?, context: ModelContext) -> Double {
        let km = Double(getKmDriven(forMonth: month, year: year, context: context))
        let liters = getFuelUsed(forMonth: month, year: year, context: context)
        guard liters > 0 else { return 0 }
        return km / liters
    }

    // MARK: - Maintenance

    public func saveMaintenance(maintenance: Maintenance, context: ModelContext) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        vehicle.maintenances.append(maintenance)
        try context.save()
    }

    public func deleteMaintenance(maintenance: Maintenance, context: ModelContext) throws {
        context.delete(maintenance)
        try context.save()
    }

    public func resetMaintenance(context: ModelContext) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        vehicle.maintenances.removeAll()
        try context.save()
    }

    // MARK: - Helpers

    private func getOrCreateMileage(vehicle: Vehicle, mileageValue: Int, context: ModelContext) -> Mileage {
        if let existing = vehicle.mileages.first(where: { $0.value == mileageValue }) {
            return existing
        }
        let mileage = Mileage(value: mileageValue, date: Date(), vehicle: vehicle)
        vehicle.mileages.append(mileage)
        context.insert(mileage)
        return mileage
    }

    private func dateRange(forMonth month: Int, year: Int?) -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let currentYear = year ?? calendar.component(.year, from: Date())
        guard let startOfMonth = calendar.date(from: DateComponents(year: currentYear, month: month, day: 1)) else { return nil }
        var comps = DateComponents()
        comps.month = 1
        comps.second = -1
        guard let endOfMonth = calendar.date(byAdding: comps, to: startOfMonth) else { return nil }
        return (start: startOfMonth, end: endOfMonth)
    }
}
