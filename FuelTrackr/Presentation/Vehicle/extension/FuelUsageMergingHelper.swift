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
        
        for usage in sorted {
            currentGroup.append(usage)
            
            // If this is not a partial fill, close the current group
            if !usage.isPartialFill {
                if !currentGroup.isEmpty {
                    groups.append(currentGroup)
                    currentGroup = []
                }
            }
        }
        
        // If there are remaining partial fills at the end, add them as a group
        // (they'll show 0 consumption until a full fill is added)
        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }
        
        return groups
    }
    
    /// Calculates consumption for a merged group of fuel usages
    /// - Parameters:
    ///   - group: Array of fuel usages (partial fills + final full fill)
    ///   - previousMileage: The mileage before this group started
    ///   - fuelType: The vehicle's fuel type
    ///   - isUsingMetric: Whether to use metric or imperial units
    /// - Returns: Consumption rate (in appropriate unit for fuel type) or nil if calculation not possible
    static func calculateConsumptionForGroup(
        _ group: [FuelUsage],
        previousMileage: Int?,
        fuelType: FuelType? = nil,
        isUsingMetric: Bool = true
    ) -> Double? {
        guard let lastUsage = group.last,
              let endMileage = lastUsage.mileage?.value else {
            return nil
        }
        
        guard let startMileage = previousMileage else {
            return nil
        }
        
        guard endMileage > startMileage else {
            return nil
        }
        
        // Sum all fuel in the group
        let totalFuel = group.reduce(0.0) { $0 + $1.liters }
        guard totalFuel > 0 else {
            return nil
        }
        
        let distance = Double(endMileage - startMileage)
        
        // Use fuel type-aware calculation if available, otherwise fall back to liquid (km/L)
        let fuelTypeToUse = fuelType ?? .liquid
        return fuelTypeToUse.calculateConsumption(
            distance: distance,
            fuelAmount: totalFuel,
            isUsingMetric: isUsingMetric
        )
    }
}

