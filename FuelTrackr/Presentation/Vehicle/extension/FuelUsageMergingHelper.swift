//
//  FuelUsageMergingHelper.swift
//  FuelTrackr
//
//  Created on 2025.
//

import Foundation
import Domain

/// Helper to merge partial fills for consumption calculations
struct FuelUsageMergingHelper {
    /// Groups fuel usages into merged groups where partial fills are combined until a full fill
    /// Returns groups of fuel usages, where each group represents one consumption calculation
    static func groupMergedFuelUsages(_ usages: [FuelUsage]) -> [[FuelUsage]] {
        // Sort oldest to newest for proper grouping
        let sorted = usages.sorted { $0.date < $1.date }
        var groups: [[FuelUsage]] = []
        var currentGroup: [FuelUsage] = []
        
        print("🔄 [FuelUsageMergingHelper] Grouping \(sorted.count) fuel usages...")
        
        for (index, usage) in sorted.enumerated() {
            let isPartial = usage.isPartialFill
            print("   Entry \(index + 1): \(String(format: "%.2f", usage.liters))L @ \(usage.mileage?.value ?? 0)km - \(isPartial ? "PARTIAL" : "FULL")")
            
            currentGroup.append(usage)
            
            // If this is not a partial fill, close the current group
            if !usage.isPartialFill {
                if !currentGroup.isEmpty {
                    let totalFuel = currentGroup.reduce(0.0) { $0 + $1.liters }
                    print("   → Closing group with \(currentGroup.count) entries, total: \(String(format: "%.2f", totalFuel))L")
                    groups.append(currentGroup)
                    currentGroup = []
                }
            }
        }
        
        // If there are remaining partial fills at the end, add them as a group
        // (they'll show 0 consumption until a full fill is added)
        if !currentGroup.isEmpty {
            let totalFuel = currentGroup.reduce(0.0) { $0 + $1.liters }
            print("   → Final group (partial fills only) with \(currentGroup.count) entries, total: \(String(format: "%.2f", totalFuel))L")
            groups.append(currentGroup)
        }
        
        print("🔄 [FuelUsageMergingHelper] Created \(groups.count) merged group(s)")
        return groups
    }
    
    /// Calculates consumption for a merged group of fuel usages
    /// - Parameters:
    ///   - group: Array of fuel usages (partial fills + final full fill)
    ///   - previousMileage: The mileage before this group started
    /// - Returns: Consumption rate (km/l) or nil if calculation not possible
    static func calculateConsumptionForGroup(_ group: [FuelUsage], previousMileage: Int?) -> Double? {
        guard let lastUsage = group.last,
              let endMileage = lastUsage.mileage?.value else {
            print("   ❌ [FuelUsageMergingHelper] Cannot calculate: missing end mileage")
            return nil
        }
        
        guard let startMileage = previousMileage else {
            print("   ❌ [FuelUsageMergingHelper] Cannot calculate: missing start mileage")
            return nil
        }
        
        guard endMileage > startMileage else {
            print("   ❌ [FuelUsageMergingHelper] Cannot calculate: end (\(endMileage)) <= start (\(startMileage))")
            return nil
        }
        
        // Sum all fuel in the group
        let totalFuel = group.reduce(0.0) { $0 + $1.liters }
        guard totalFuel > 0 else {
            print("   ❌ [FuelUsageMergingHelper] Cannot calculate: total fuel is 0")
            return nil
        }
        
        let distance = Double(endMileage - startMileage)
        let consumption = distance / totalFuel
        
        print("   ✅ [FuelUsageMergingHelper] Consumption calculated:")
        print("      - Distance: \(distance) km (\(startMileage) → \(endMileage))")
        print("      - Total fuel: \(String(format: "%.2f", totalFuel)) L")
        print("      - Consumption: \(String(format: "%.2f", consumption)) km/L")
        
        return consumption
    }
}

