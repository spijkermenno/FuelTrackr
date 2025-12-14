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
}
