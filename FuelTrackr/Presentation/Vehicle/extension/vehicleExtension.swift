//
//  vehicleExtension.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 02/06/2025.
//

import Foundation
import Domain
import SwiftData

public extension Vehicle {
    /// Returns up to `limit` latest fuel-usage previews (newest first).
    /// Economy is computed as km / liters between this entry's mileage and the previous valid mileage entry.
    /// Partial fills are merged until a full fill is reached.
    func latestFuelUsagePreviews(limit: Int = 3) -> [FuelUsagePreviewUiModel] {
        let groups = FuelUsageMergingHelper.groupMergedFuelUsages(fuelUsages)
        var previews: [FuelUsagePreviewUiModel] = []
        
        // Process groups from oldest to newest to correctly track previous mileage
        // First, get all fuel usages sorted by date to find previous mileage
        let sortedAllUsages = fuelUsages.sorted { $0.date < $1.date }
        var previousMileage: Int?
        
        for group in groups {
            guard let firstUsage = group.first,
                  let lastUsage = group.last else { continue }
            
            // Get start mileage: use previous group's end mileage, or find the mileage before first usage
            let startMileage: Int
            if let prevMileage = previousMileage {
                startMileage = prevMileage
            } else {
                // For the first group, find the mileage before the first usage in this group
                if let firstIndex = sortedAllUsages.firstIndex(where: { $0.persistentModelID == firstUsage.persistentModelID }),
                   firstIndex > 0 {
                    // Use the mileage from the previous fuel usage entry
                    startMileage = sortedAllUsages[firstIndex - 1].mileage?.value ?? (lastUsage.mileage?.value ?? 0)
                } else {
                    // This is the very first fuel usage, can't calculate consumption
                    startMileage = lastUsage.mileage?.value ?? 0
                }
            }
            
            // Calculate consumption for merged group
            let economy: Double
            if let currentMileage = lastUsage.mileage?.value,
               currentMileage > startMileage {
                let totalFuel = group.reduce(0.0) { $0 + $1.liters }
                if totalFuel > 0 {
                    let kmDriven = currentMileage - startMileage
                    economy = Double(kmDriven) / totalFuel
                } else {
                    economy = .zero
                }
            } else {
                economy = .zero
            }
            
            // Sum fuel and cost for the group
            let totalFuel = group.reduce(0.0) { $0 + $1.liters }
            let totalCost = group.reduce(0.0) { $0 + $1.cost }
            
            previews.append(
                FuelUsagePreviewUiModel(
                    fuelUsageID: lastUsage.persistentModelID, // ⟵ critical for onEdit
                    date: lastUsage.date,
                    liters: totalFuel,
                    cost: totalCost,
                    economy: economy
                )
            )
            
            // Update previous mileage for next iteration
            if let endMileage = lastUsage.mileage?.value {
                previousMileage = endMileage
            }
        }

        // Reverse to show newest first, then limit
        return Array(previews.reversed().prefix(limit))
    }

    func latestMaintenancePreviews() -> [MaintenancePreviewUiModel] {
        self.maintenances
            .sorted(by: { $0.date > $1.date })
            .prefix(3)
            .map {
                MaintenancePreviewUiModel(
                    date: $0.date,
                    type: $0.type,
                    cost: $0.cost,
                    notes: $0.notes,
                    isFree: $0.isFree
                )
            }
    }
    
    /// Returns monthly fuel summary for a specific month/year
    /// Note: This requires repository methods to be called externally
    func monthlyFuelSummary(month: Int, year: Int, totalDistance: Double, totalFuel: Double, totalCost: Double) -> MonthlyFuelSummaryUiModel {
        // Calculate average price per liter
        let averagePricePerLiter: Double
        if totalFuel > 0 {
            // Get all fuel entries for the month and calculate weighted average
            let calendar = Calendar.current
            let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
            let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
            
            let monthEntries = fuelUsages.filter { $0.date >= monthStart && $0.date <= monthEnd }
            if !monthEntries.isEmpty {
                let totalPrice = monthEntries.reduce(0.0) { $0 + ($1.liters > 0 ? ($1.cost / $1.liters) * $1.liters : 0) }
                averagePricePerLiter = totalFuel > 0 ? totalPrice / totalFuel : 0
            } else {
                averagePricePerLiter = totalFuel > 0 ? totalCost / totalFuel : 0
            }
        } else {
            averagePricePerLiter = 0
        }
        
        return MonthlyFuelSummaryUiModel(
            month: month,
            year: year,
            totalDistance: totalDistance,
            averagePricePerLiter: averagePricePerLiter,
            totalFuelVolume: totalFuel,
            totalCost: totalCost
        )
    }
    
    /// Returns fuel consumption entries for the new design
    /// Partial fills are merged until a full fill is reached
    func fuelConsumptionEntries(limit: Int = 3) -> [FuelConsumptionEntryUiModel] {
        Swift.print("📊 [Vehicle] Calculating fuel consumption entries (limit: \(limit))")
        let groups = FuelUsageMergingHelper.groupMergedFuelUsages(fuelUsages)
        var entries: [FuelConsumptionEntryUiModel] = []
        
        // Process groups from oldest to newest to correctly track previous mileage
        // First, get all fuel usages sorted by date to find previous mileage
        let sortedAllUsages = fuelUsages.sorted { $0.date < $1.date }
        var previousMileage: Int?
        
        Swift.print("📊 [Vehicle] Processing \(groups.count) merged group(s)...")
        
        for (groupIndex, group) in groups.enumerated() {
            Swift.print("   📦 Processing group \(groupIndex + 1)/\(groups.count)...")
            guard let firstUsage = group.first,
                  let lastUsage = group.last,
                  let endMileage = lastUsage.mileage?.value else {
                Swift.print("   ❌ Skipping group: missing mileage data")
                continue
            }
            
            // Get start mileage: use previous group's end mileage, or find the mileage before first usage
            let startMileage: Int
            if let prevMileage = previousMileage {
                startMileage = prevMileage
                Swift.print("   📍 Using previous group's end mileage: \(startMileage) km")
            } else {
                // For the first group, find the mileage before the first usage in this group
                if let firstIndex = sortedAllUsages.firstIndex(where: { $0.persistentModelID == firstUsage.persistentModelID }),
                   firstIndex > 0 {
                    // Use the mileage from the previous fuel usage entry
                    startMileage = sortedAllUsages[firstIndex - 1].mileage?.value ?? (firstUsage.mileage?.value ?? endMileage)
                    Swift.print("   📍 Using previous entry's mileage: \(startMileage) km (from entry \(firstIndex))")
                } else {
                    // This is the very first fuel usage - use the first entry's mileage in the group as start
                    startMileage = firstUsage.mileage?.value ?? endMileage
                    Swift.print("   ⚠️  First fuel usage - using first entry's mileage as start: \(startMileage) km")
                }
            }
            
            // Calculate consumption for merged group
            let consumptionRate = FuelUsageMergingHelper.calculateConsumptionForGroup(group, previousMileage: startMileage) ?? 0
            
            // Sum fuel and cost for the group
            let totalFuel = group.reduce(0.0) { $0 + $1.liters }
            let totalCost = group.reduce(0.0) { $0 + $1.cost }
            let pricePerLiter = totalFuel > 0 ? totalCost / totalFuel : 0
            
            let distanceDriven = max(0, endMileage - startMileage)
            
            Swift.print("   ✅ Entry created: \(String(format: "%.2f", consumptionRate)) km/L, \(distanceDriven) km, \(String(format: "%.2f", totalFuel))L")
            
            // Check if this group contains any partial fills
            let hasPartialFills = group.contains { $0.isPartialFill }
            
            // Use the last usage's date and ID for display
            entries.append(
                FuelConsumptionEntryUiModel(
                    fuelUsageID: lastUsage.persistentModelID,
                    date: lastUsage.date,
                    startOdometer: startMileage,
                    endOdometer: endMileage,
                    fuelVolume: totalFuel,
                    pricePerLiter: pricePerLiter,
                    totalCost: totalCost,
                    consumptionRate: consumptionRate,
                    distanceDriven: distanceDriven,
                    containsPartialFills: hasPartialFills
                )
            )
            
            // Update previous mileage for next iteration
            previousMileage = endMileage
        }
        
        // Reverse to show newest first, then limit
        let result = Array(entries.reversed().prefix(limit))
        Swift.print("📊 [Vehicle] Returning \(result.count) entry/entries")
        return result
    }
    
    /// Returns maintenance entries for the new design
    func maintenanceEntries(limit: Int = 3) -> [MaintenanceEntryUiModel] {
        self.maintenances
            .sorted(by: { $0.date > $1.date })
            .prefix(limit)
            .map {
                MaintenanceEntryUiModel(
                    maintenanceID: $0.persistentModelID,
                    date: $0.date,
                    type: $0.type,
                    odometerAtMaintenance: $0.mileage?.value ?? 0,
                    cost: $0.cost,
                    isFree: $0.isFree
                )
            }
    }
}
