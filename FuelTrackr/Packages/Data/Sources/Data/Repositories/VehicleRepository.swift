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
        let vehicle = try context.fetch(FetchDescriptor<Vehicle>()).first
        return vehicle
    }
    
    public func refreshActiveVehicle(context: ModelContext) throws -> Vehicle? {
        try loadActiveVehicle(context: context)
    }
    
    public func saveVehicle(
        vehicle: Vehicle,
        initialMileage: Int,
        context: ModelContext
    ) throws {
        context.insert(vehicle)
        
        if initialMileage > 0 {
            let mileage = Mileage(
                value: initialMileage,
                date: .now,
                vehicle: vehicle
            )
            context.insert(mileage)
            
            // Ensure the array exists before appending
            if vehicle.mileages == nil {
                vehicle.mileages = []
            }
            vehicle.mileages?.append(mileage)
        }
        
        try context.save()
    }
    
    public func updateVehicle(vehicle: Vehicle, context: ModelContext) throws {
        try context.save()
    }
    
    public func deleteVehicle(context: ModelContext) throws {
        for vehicle in try context.fetch(FetchDescriptor<Vehicle>()) {
            context.delete(vehicle)
        }
        try context.save()
    }
    
    public func updateVehiclePurchaseStatus(
        isPurchased: Bool,
        context: ModelContext
    ) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        vehicle.isPurchased = isPurchased
        try context.save()
    }
    
    public func migrateVehicles(context: ModelContext) throws {
        for vehicle in try context.fetch(FetchDescriptor<Vehicle>()) {
            if vehicle.isPurchased == nil {
                vehicle.isPurchased = vehicle.purchaseDate.map { $0 <= Date() } ?? false
            }
        }
        try context.save()
    }
    
    // MARK: - Fuel Usage
    
    public func saveFuelUsage(
        liters: Double,
        cost: Double,
        mileageValue: Int,
        context: ModelContext
    ) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        
        let mileage = getOrCreateMileage(
            vehicle: vehicle,
            mileageValue: mileageValue,
            context: context
        )
        
        let fuelUsage = FuelUsage(
            liters: liters,
            cost: cost,
            date: .now,
            mileage: mileage,
            vehicle: vehicle
        )
        context.insert(fuelUsage)
        
        // Ensure the array exists before appending
        if vehicle.fuelUsages == nil {
            vehicle.fuelUsages = []
        }
        vehicle.fuelUsages?.append(fuelUsage)
        
        try context.save()
    }
    
    public func deleteFuelUsage(
        fuelUsage: FuelUsage,
        context: ModelContext
    ) throws {
        context.delete(fuelUsage)
        try context.save()
    }
    
    public func resetFuelUsage(context: ModelContext) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        vehicle.fuelUsages = []
        try context.save()
    }
    
    public func getFuelUsed(
        forMonth month: Int,
        year: Int?,
        context: ModelContext
    ) -> Double {
        guard
            let vehicle = try? loadActiveVehicle(context: context),
            let range = dateRange(forMonth: month, year: year)
        else { return 0 }
        
        return (vehicle.fuelUsages ?? [])
            .compactMap { usage in
                guard
                    let d = usage.date,
                    let liters = usage.liters,
                    d >= range.start && d <= range.end
                else {
                    return nil
                }
                return liters
            }
            .reduce(0) { $0 + $1 }
    }
    
    public func getFuelCost(
        forMonth month: Int,
        year: Int?,
        context: ModelContext
    ) -> Double {
        guard
            let vehicle = try? loadActiveVehicle(context: context),
            let range = dateRange(forMonth: month, year: year)
        else { return 0 }
        
        return (vehicle.fuelUsages ?? [])
            .compactMap { usage in
                guard
                    let d = usage.date,
                    let c = usage.cost,
                    d >= range.start && d <= range.end
                else {
                    return nil
                }
                return c
            }
            .reduce(0) { $0 + $1 }
    }
    
    public func getKmDriven(
        forMonth month: Int,
        year: Int?,
        context: ModelContext
    ) -> Int {
        guard
            let vehicle = try? loadActiveVehicle(context: context),
            let range = dateRange(forMonth: month, year: year)
        else { return 0 }
        
        // Filter and sort only those mileages with non-nil date and value
        let filtered = (vehicle.mileages ?? []).compactMap { m -> (date: Date, value: Int)? in
            guard
                let d = m.date,
                let v = m.value,
                d >= range.start && d <= range.end
            else {
                return nil
            }
            return (date: d, value: v)
        }
        let sorted = filtered.sorted { $0.date < $1.date }
        
        guard let first = sorted.first, let last = sorted.last else { return 0 }
        return last.value - first.value
    }
    
    public func getAverageFuelUsage(
        forMonth month: Int,
        year: Int?,
        context: ModelContext
    ) -> Double {
        let km = Double(getKmDriven(forMonth: month, year: year, context: context))
        let liters = getFuelUsed(forMonth: month, year: year, context: context)
        guard liters > 0 else { return 0 }
        return km / liters
    }
    
    // MARK: - Maintenance
    
    public func saveMaintenance(
        maintenance: Maintenance,
        context: ModelContext
    ) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        
        // Ensure the array exists before appending
        if vehicle.maintenances == nil {
            vehicle.maintenances = []
        }
        vehicle.maintenances?.append(maintenance)
        
        try context.save()
    }
    
    public func deleteMaintenance(
        maintenance: Maintenance,
        context: ModelContext
    ) throws {
        context.delete(maintenance)
        try context.save()
    }
    
    public func resetMaintenance(context: ModelContext) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        vehicle.maintenances = []
        try context.save()
    }
    
    // MARK: - Helpers
    
    private func getOrCreateMileage(
        vehicle: Vehicle,
        mileageValue: Int,
        context: ModelContext
    ) -> Mileage {
        // Search using non-nil mileage values
        if let existing = (vehicle.mileages ?? []).first(where: { $0.value == mileageValue }) {
            return existing
        }
        let mileage = Mileage(value: mileageValue, date: .now, vehicle: vehicle)
        context.insert(mileage)
        
        // Ensure the array exists before appending
        if vehicle.mileages == nil {
            vehicle.mileages = []
        }
        vehicle.mileages?.append(mileage)
        return mileage
    }
    
    private func dateRange(forMonth month: Int, year: Int?) -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let currentYear = year ?? calendar.component(.year, from: .now)
        guard let start = calendar.date(from: DateComponents(year: currentYear, month: month, day: 1))
        else { return nil }
        
        var comps = DateComponents()
        comps.month = 1
        comps.second = -1
        guard let end = calendar.date(byAdding: comps, to: start)
        else { return nil }
        
        return (start: start, end: end)
    }
    
    // MARK: - Debug
    
}

extension Vehicle {
    public func print() {
        let mileages = (self.mileages ?? []).compactMap { m in
            m.value.map { String($0) }
        }
        let fuelUsages = (self.fuelUsages ?? []).compactMap { u in
            guard
                let liters = u.liters,
                let cost = u.cost,
                let date = u.date
            else {
                return nil
            }
            return "Liters: \(liters), Cost: \(cost), Date: \(date)"
        }
        let maintenances = (self.maintenances ?? []).compactMap { m in
            guard
                let type = m.type,
                let cost = m.cost,
                let date = m.date
            else {
                return nil
            }
            return "\(type.rawValue), Cost: \(cost), Date: \(date)"
        }

        Swift.print("--- Active Vehicle Info ---")
        Swift.print("Name: \(self.name ?? "")")
        Swift.print("License Plate: \(self.licensePlate ?? "")")
        Swift.print("Purchase Date: \(self.purchaseDate.map(String.init) ?? "nil")")
        Swift.print("Manufacturing Date: \(self.manufacturingDate.map(String.init) ?? "nil")")
        Swift.print("Is Purchased: \(self.isPurchased.map(String.init) ?? "nil")")
        Swift.print("Photo size: \(self.photo?.count ?? 0) bytes")
        Swift.print("Mileages: \(mileages)")
        Swift.print("Fuel Usages: \(fuelUsages)")
        Swift.print("Maintenances: \(maintenances)")
        Swift.print("--------------------------")
    }
}
