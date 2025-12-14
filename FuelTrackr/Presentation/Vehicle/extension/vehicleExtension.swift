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
    func latestFuelUsagePreviews(limit: Int = 3) -> [FuelUsagePreviewUiModel] {
        // Newest first
        let sorted = fuelUsages.sorted { $0.date > $1.date }
        var previews: [FuelUsagePreviewUiModel] = []
        previews.reserveCapacity(min(limit, sorted.count))

        for i in 0..<sorted.count {
            let usage = sorted[i]

            // Find the next older usage that actually has a mileage value
            var previousMileageValue: Int?
            if let currentMileage = usage.mileage?.value {
                var j = i + 1
                while j < sorted.count, previousMileageValue == nil {
                    if let prevVal = sorted[j].mileage?.value {
                        previousMileageValue = prevVal
                    }
                    j += 1
                }

                // Compute km driven only if we have a valid previous mileage
                let kmDriven: Int
                if let prev = previousMileageValue {
                    kmDriven = max(0, currentMileage - prev) // prevent negatives
                } else {
                    kmDriven = 0
                }

                // Compute economy safely
                let economy: Double
                if usage.liters > 0, kmDriven > 0 {
                    economy = Double(kmDriven) / usage.liters
                } else {
                    economy = .zero
                }

                previews.append(
                    FuelUsagePreviewUiModel(
                        fuelUsageID: usage.persistentModelID, // ⟵ critical for onEdit
                        date: usage.date,
                        liters: usage.liters,
                        cost: usage.cost,
                        economy: economy
                    )
                )
            } else {
                // No mileage on this usage; we can still show the row with 0 economy
                previews.append(
                    FuelUsagePreviewUiModel(
                        fuelUsageID: usage.persistentModelID,
                        date: usage.date,
                        liters: usage.liters,
                        cost: usage.cost,
                        economy: .zero
                    )
                )
            }

            if previews.count >= limit { break }
        }

        return previews
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
    func fuelConsumptionEntries(limit: Int = 3) -> [FuelConsumptionEntryUiModel] {
        let sorted = fuelUsages.sorted { $0.date > $1.date }
        var entries: [FuelConsumptionEntryUiModel] = []
        entries.reserveCapacity(min(limit, sorted.count))
        
        for i in 0..<sorted.count {
            let usage = sorted[i]
            
            guard let currentMileage = usage.mileage?.value else {
                // Skip entries without mileage
                continue
            }
            
            // Find previous mileage
            var previousMileage: Int?
            var j = i + 1
            while j < sorted.count, previousMileage == nil {
                if let prevVal = sorted[j].mileage?.value {
                    previousMileage = prevVal
                }
                j += 1
            }
            
            let startOdometer = previousMileage ?? currentMileage
            let endOdometer = currentMileage
            let distanceDriven = max(0, endOdometer - startOdometer)
            
            let pricePerLiter = usage.liters > 0 ? usage.cost / usage.liters : 0
            let consumptionRate = usage.liters > 0 && distanceDriven > 0 ? Double(distanceDriven) / usage.liters : 0
            
            entries.append(
                FuelConsumptionEntryUiModel(
                    fuelUsageID: usage.persistentModelID,
                    date: usage.date,
                    startOdometer: startOdometer,
                    endOdometer: endOdometer,
                    fuelVolume: usage.liters,
                    pricePerLiter: pricePerLiter,
                    totalCost: usage.cost,
                    consumptionRate: consumptionRate,
                    distanceDriven: distanceDriven
                )
            )
            
            if entries.count >= limit { break }
        }
        
        return entries
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
