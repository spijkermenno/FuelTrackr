//
//  PartialFillDetector.swift
//  Domain
//
//  Created on 2025.
//

import Foundation

public struct PartialFillDetector {
    /// Minimum number of refills needed before we can detect partial fills
    public static let minimumRefillsForDetection = 3
    
    /// Threshold percentage: if a refill is less than this percentage of average, it's considered partial
    /// Using 70% as threshold - if a refill is less than 70% of average, it's likely partial
    public static let partialFillThreshold: Double = 0.70
    
    /// Detects if a fuel usage is a partial fill based on historical data
    /// - Parameters:
    ///   - liters: The liters amount of the current fill
    ///   - vehicle: The vehicle to check historical data for
    /// - Returns: true if this appears to be a partial fill, false otherwise
    public static func detectPartialFill(liters: Double, vehicle: Vehicle) -> Bool {
        // Need at least minimumRefillsForDetection refills before we can detect
        let sortedUsages = vehicle.fuelUsages.sorted { $0.date < $1.date }
        
        guard sortedUsages.count >= minimumRefillsForDetection else {
            return false
        }
        
        // Calculate average refill amount from historical data
        let averageLiters = sortedUsages.map { $0.liters }.reduce(0, +) / Double(sortedUsages.count)
        let threshold = averageLiters * partialFillThreshold
        
        return liters < threshold
    }
    
    /// Calculates the average refill amount for a vehicle
    /// - Parameter vehicle: The vehicle to calculate average for
    /// - Returns: Average liters per refill, or nil if not enough data
    public static func averageRefillAmount(vehicle: Vehicle) -> Double? {
        guard vehicle.fuelUsages.count >= minimumRefillsForDetection else {
            return nil
        }
        
        return vehicle.fuelUsages.map { $0.liters }.reduce(0, +) / Double(vehicle.fuelUsages.count)
    }
    
    /// Checks if vehicle has enough data to detect partial fills
    /// - Parameter vehicle: The vehicle to check
    /// - Returns: true if we have enough refills to detect partial fills
    public static func canDetectPartialFills(vehicle: Vehicle) -> Bool {
        return vehicle.fuelUsages.count >= minimumRefillsForDetection
    }
}

