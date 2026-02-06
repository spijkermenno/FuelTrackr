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
            vehicle.mileages.append(mileage)
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
                vehicle.isPurchased = vehicle.purchaseDate <= Date()
            }
            
            // Migrate existing fuel usages to detect partial fills
            // Only detect if not manually set and we have enough data
            print("🔄 [VehicleRepository] Migrating vehicle: \(vehicle.name)")
            print("   Total fuel usages: \(vehicle.fuelUsages.count)")
            
            if PartialFillDetector.canDetectPartialFills(vehicle: vehicle) {
                print("   ✅ Can detect partial fills - processing \(vehicle.fuelUsages.count) entries...")
                var detectedCount = 0
                for fuelUsage in vehicle.fuelUsages {
                    // Only auto-detect if not manually set
                    if !fuelUsage.isPartialFillManuallySet {
                        let wasPartial = fuelUsage.isPartialFill
                        let isPartialFill = PartialFillDetector.detectPartialFill(liters: fuelUsage.liters, vehicle: vehicle)
                        fuelUsage.isPartialFill = isPartialFill
                        if isPartialFill && !wasPartial {
                            detectedCount += 1
                            print("   🔍 Detected partial fill: \(String(format: "%.2f", fuelUsage.liters))L")
                        }
                    } else {
                        print("   ⏭️  Skipping manually set entry: \(String(format: "%.2f", fuelUsage.liters))L (isPartial: \(fuelUsage.isPartialFill))")
                    }
                }
                print("   ✅ Migration complete: \(detectedCount) new partial fills detected")
            } else {
                print("   ⚠️  Not enough data for detection (need \(PartialFillDetector.minimumRefillsForDetection) refills)")
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
        
        // Detect if this is a partial fill (only if not manually set before)
        print("💾 [VehicleRepository] Saving fuel usage: \(liters)L @ \(mileageValue)km")
        let isPartialFill = PartialFillDetector.detectPartialFill(liters: liters, vehicle: vehicle)
        
        let fuelUsage = FuelUsage(
            liters: liters,
            cost: cost,
            date: .now,
            mileage: mileage,
            vehicle: vehicle,
            isPartialFill: isPartialFill,
            isPartialFillManuallySet: false
        )
        vehicle.fuelUsages.append(fuelUsage)
        
        print("💾 [VehicleRepository] Fuel usage saved: \(isPartialFill ? "MARKED AS PARTIAL" : "MARKED AS FULL")")
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
        vehicle.fuelUsages.removeAll()
        try context.save()
    }
    
    public func getFuelUsage(id: PersistentIdentifier, context: ModelContext) throws -> FuelUsage? {
        context.model(for: id) as? FuelUsage
    }

    public func updateFuelUsage(
        id: PersistentIdentifier,
        liters: Double,
        cost: Double,
        mileageValue: Int,
        context: ModelContext
    ) throws {
        guard let fuelUsage = try getFuelUsage(id: id, context: context),
              let vehicle = try loadActiveVehicle(context: context)
        else { return }

        // (Re)link mileage (create if needed)
        let mileage = getOrCreateMileage(
            vehicle: vehicle,
            mileageValue: mileageValue,
            context: context
        )
        fuelUsage.liters = liters
        fuelUsage.cost = cost
        fuelUsage.mileage = mileage
        // keep original date (or change if you want a date field in the sheet)

        try context.save()
    }
    
    public func updateFuelUsagePartialFillStatus(
        id: PersistentIdentifier,
        isPartialFill: Bool,
        context: ModelContext
    ) throws {
        guard let fuelUsage = try getFuelUsage(id: id, context: context) else { return }
        
        fuelUsage.isPartialFill = isPartialFill
        fuelUsage.isPartialFillManuallySet = true
        
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
        
        return vehicle.fuelUsages
            .filter { $0.date >= range.start && $0.date <= range.end }
            .reduce(0) { $0 + $1.liters }
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
        
        return vehicle.fuelUsages
            .filter { $0.date >= range.start && $0.date <= range.end }
            .reduce(0) { $0 + $1.cost }
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
        
        let allMileages = vehicle.mileages.sorted { $0.date < $1.date }
        
        // First mileage in the month
        guard let firstInMonth = allMileages.first(where: { $0.date >= range.start && $0.date <= range.end }) else {
            return 0
        }
        
        // Last mileage in the month
        guard let lastInMonth = allMileages.last(where: { $0.date >= range.start && $0.date <= range.end }) else {
            return 0
        }
        
        // Latest mileage BEFORE the first one in the month
        guard let previousMileage = allMileages.last(where: { $0.date < firstInMonth.date }) else {
            return 0 // Or assume 0 km if there's no earlier entry
        }
        
        let driven = lastInMonth.value - previousMileage.value
        return max(0, driven) // Avoid negative values
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
        vehicle.maintenances.append(maintenance)
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
        vehicle.maintenances.removeAll()
        try context.save()
    }
    
    // MARK: - Helpers
    
    private func getOrCreateMileage(
        vehicle: Vehicle,
        mileageValue: Int,
        context: ModelContext
    ) -> Mileage {
        if let existing = vehicle.mileages.first(where: { $0.value == mileageValue }) {
            return existing
        }
        let mileage = Mileage(value: mileageValue, date: .now, vehicle: vehicle)
        context.insert(mileage)
        vehicle.mileages.append(mileage)
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
        let mileages     = self.mileages.map { "\($0.value)" }
        let fuelUsages   = self.fuelUsages
            .map { "Liters: \($0.liters), Cost: \($0.cost), Date: \($0.date)" }
        let maintenances = self.maintenances
            .map { "\($0.type.rawValue), Cost: \($0.cost), Date: \($0.date)" }

     Swift.print("--- Active Vehicle Info ---")
     Swift.print("Name: \(self.name)")
     Swift.print("Purchase Date: \(self.purchaseDate)")
     Swift.print("Manufacturing Date: \(self.manufacturingDate)")
     Swift.print("Is Purchased: \(self.isPurchased.map(String.init) ?? "nil")")
     Swift.print("Photo size: \(self.photo?.count ?? 0) bytes")
     Swift.print("Mileages: \(mileages)")
     Swift.print("Fuel Usages: \(fuelUsages)")
     Swift.print("Maintenances: \(maintenances)")
     Swift.print("--------------------------")
    }
}
