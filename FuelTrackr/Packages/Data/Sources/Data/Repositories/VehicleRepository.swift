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

    /// Updates the current odometer reading. When the vehicle has no fuel entries, updates the latest mileage.
    /// When the vehicle has data, adds a new mileage record (with strong warning shown in UI).
    public func updateOdometer(vehicle: Vehicle, newValue: Int, context: ModelContext) throws {
        guard newValue > 0 else { return }

        let hasFuelData = !vehicle.fuelUsages.isEmpty
        let hasMaintenanceWithMileage = vehicle.maintenances.contains { $0.mileage != nil }

        if !hasFuelData && !hasMaintenanceWithMileage {
            // No fuel/maintenance data: update the latest standalone mileage if it exists and isn't linked to anything
            if let latest = vehicle.latestMileage,
               !vehicle.fuelUsages.contains(where: { $0.mileage?.persistentModelID == latest.persistentModelID }),
               !vehicle.maintenances.contains(where: { $0.mileage?.persistentModelID == latest.persistentModelID }) {
                latest.value = newValue
                latest.date = Date()
            } else {
                // No standalone mileage or all are linked: add new one
                let mileage = Mileage(value: newValue, date: Date(), vehicle: vehicle)
                context.insert(mileage)
                vehicle.mileages.append(mileage)
            }
        } else {
            // Has data: always add new mileage record as the "current" reading
            let mileage = Mileage(value: newValue, date: Date(), vehicle: vehicle)
            context.insert(mileage)
            vehicle.mileages.append(mileage)
        }

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
            if PartialFillDetector.canDetectPartialFills(vehicle: vehicle) {
                for fuelUsage in vehicle.fuelUsages {
                    // Only auto-detect if not manually set
                    if !fuelUsage.isPartialFillManuallySet {
                        let isPartialFill = PartialFillDetector.detectPartialFill(liters: fuelUsage.liters, vehicle: vehicle)
                        fuelUsage.isPartialFill = isPartialFill
                    }
                }
            }
        }
        try context.save()
    }
    
    // MARK: - Fuel Usage
    
    public func saveFuelUsage(
        liters: Double,
        cost: Double,
        mileageValue: Int,
        date: Date,
        context: ModelContext
    ) throws {
        guard let vehicle = try loadActiveVehicle(context: context) else { return }
        
        let mileage = getOrCreateMileage(
            vehicle: vehicle,
            mileageValue: mileageValue,
            date: date,
            context: context
        )
        
        // Detect if this is a partial fill (only if not manually set before)
        let isPartialFill = PartialFillDetector.detectPartialFill(liters: liters, vehicle: vehicle)
        
        let fuelUsage = FuelUsage(
            liters: liters,
            cost: cost,
            date: date,
            mileage: mileage,
            vehicle: vehicle,
            isPartialFill: isPartialFill,
            isPartialFillManuallySet: false
        )
        vehicle.fuelUsages.append(fuelUsage)
        
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
        date: Date,
        context: ModelContext
    ) throws {
        guard let fuelUsage = try getFuelUsage(id: id, context: context),
              let vehicle = try loadActiveVehicle(context: context)
        else { return }

        let mileage = getOrCreateMileage(
            vehicle: vehicle,
            mileageValue: mileageValue,
            date: date,
            context: context
        )
        fuelUsage.liters = liters
        fuelUsage.cost = cost
        fuelUsage.date = date
        fuelUsage.mileage = mileage

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
        guard let vehicle = try? loadActiveVehicle(context: context) else {
            return 0
        }
        
        guard let range = dateRange(forMonth: month, year: year) else {
            return 0
        }
        
        let allMileages = vehicle.mileages.sorted { $0.date < $1.date }
        
        if allMileages.isEmpty {
            return 0
        }
        
        // First mileage in the month
        guard let firstInMonth = allMileages.first(where: { $0.date >= range.start && $0.date <= range.end }) else {
            return 0
        }
        
        // Last mileage in the month
        guard let lastInMonth = allMileages.last(where: { $0.date >= range.start && $0.date <= range.end }) else {
            return 0
        }
        
        // Latest mileage BEFORE the first one in the month
        let startMileage: Int
        if let previousMileage = allMileages.last(where: { $0.date < firstInMonth.date }) {
            startMileage = previousMileage.value
        } else {
            startMileage = firstInMonth.value
        }
        
        let driven = lastInMonth.value - startMileage
        let result = max(0, driven)
        
        return result
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
        date: Date,
        context: ModelContext
    ) -> Mileage {
        if let existing = vehicle.mileages.first(where: { $0.value == mileageValue }) {
            return existing
        }
        let mileage = Mileage(value: mileageValue, date: date, vehicle: vehicle)
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

