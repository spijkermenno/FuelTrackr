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
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Vehicle

    public func loadActiveVehicle() throws -> Vehicle? {
        let vehicles = try context.fetch(FetchDescriptor<Vehicle>())
        return vehicles.first
    }

    public func refreshActiveVehicle() throws -> Vehicle? {
        try loadActiveVehicle()
    }

    public func saveVehicle(vehicle: Vehicle, initialMileage: Int) throws {
        let mileage = Mileage(value: initialMileage, date: Date(), vehicle: vehicle)
        vehicle.mileages.append(mileage)
        context.insert(mileage)
        context.insert(vehicle)
        try context.save()
    }

    public func updateVehicle(vehicle: Vehicle) throws {
        try context.save()
    }

    public func deleteVehicle() throws {
        let vehicles = try context.fetch(FetchDescriptor<Vehicle>())
        for vehicle in vehicles {
            context.delete(vehicle)
        }
        try context.save()
    }

    public func updateVehiclePurchaseStatus(isPurchased: Bool) throws {
        guard let vehicle = try loadActiveVehicle() else { return }
        vehicle.isPurchased = isPurchased
        try context.save()
    }

    public func migrateVehicles() throws {
        let vehicles = try context.fetch(FetchDescriptor<Vehicle>())
        for vehicle in vehicles {
            if vehicle.isPurchased == nil {
                vehicle.isPurchased = vehicle.purchaseDate <= Date()
            }
        }
        try context.save()
    }

    // MARK: - Fuel Usage

    public func saveFuelUsage(liters: Double, cost: Double, mileageValue: Int) throws {
        guard let vehicle = try loadActiveVehicle() else { return }

        let mileage = getOrCreateMileage(vehicle: vehicle, mileageValue: mileageValue)
        let fuelUsage = FuelUsage(liters: liters, cost: cost, date: Date(), mileage: mileage, vehicle: vehicle)
        vehicle.fuelUsages.append(fuelUsage)

        try context.save()
    }

    public func deleteFuelUsage(fuelUsage: FuelUsage) throws {
        context.delete(fuelUsage)
        try context.save()
    }

    public func resetFuelUsage() throws {
        guard let vehicle = try loadActiveVehicle() else { return }
        vehicle.fuelUsages.removeAll()
        try context.save()
    }

    public func getFuelUsed(forMonth month: Int, year: Int?) -> Double {
        guard let vehicle = try? loadActiveVehicle(),
              let range = dateRange(forMonth: month, year: year) else { return 0 }

        let usages = vehicle.fuelUsages.filter { $0.date >= range.start && $0.date <= range.end }
        return usages.reduce(0) { $0 + $1.liters }
    }

    public func getFuelCost(forMonth month: Int, year: Int?) -> Double {
        guard let vehicle = try? loadActiveVehicle(),
              let range = dateRange(forMonth: month, year: year) else { return 0 }

        let usages = vehicle.fuelUsages.filter { $0.date >= range.start && $0.date <= range.end }
        return usages.reduce(0) { $0 + $1.cost }
    }

    public func getKmDriven(forMonth month: Int, year: Int?) -> Int {
        guard let vehicle = try? loadActiveVehicle(),
              let range = dateRange(forMonth: month, year: year) else { return 0 }

        let mileages = vehicle.mileages
            .filter { $0.date >= range.start && $0.date <= range.end }
            .sorted(by: { $0.date < $1.date })

        guard let first = mileages.first, let last = mileages.last else { return 0 }
        return last.value - first.value
    }

    public func getAverageFuelUsage(forMonth month: Int, year: Int?) -> Double {
        let km = Double(getKmDriven(forMonth: month, year: year))
        let liters = getFuelUsed(forMonth: month, year: year)
        guard liters > 0 else { return 0 }
        return km / liters
    }

    // MARK: - Maintenance

    public func saveMaintenance(maintenance: Maintenance) throws {
        guard let vehicle = try loadActiveVehicle() else { return }
        vehicle.maintenances.append(maintenance)
        try context.save()
    }

    public func deleteMaintenance(maintenance: Maintenance) throws {
        context.delete(maintenance)
        try context.save()
    }

    public func resetMaintenance() throws {
        guard let vehicle = try loadActiveVehicle() else { return }
        vehicle.maintenances.removeAll()
        try context.save()
    }

    // MARK: - Helpers

    private func getOrCreateMileage(vehicle: Vehicle, mileageValue: Int) -> Mileage {
        if let existing = vehicle.mileages.first(where: { $0.value == mileageValue }) {
            return existing
        }
        let mileage = Mileage(value: mileageValue, date: Date(), vehicle: vehicle)
        vehicle.mileages.append(mileage)
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
