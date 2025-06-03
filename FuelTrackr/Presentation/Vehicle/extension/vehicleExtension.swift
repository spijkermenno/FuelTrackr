//
//  vehicleExtension.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 02/06/2025.
//

import Domain
import SwiftData

public extension Vehicle {
    func latestFuelUsagePreviews(limit: Int = 3) -> [FuelUsagePreviewUiModel] {
        let sorted = fuelUsages.sorted { $0.date > $1.date }
        var previews: [FuelUsagePreviewUiModel] = []
        
        for index in 0..<min(limit, sorted.count) {
            let usage = sorted[index]
            let previousMileage = index + 1 < sorted.count ? sorted[index + 1].mileage : nil
            
            let kmDriven: Int
            if let current = usage.mileage, let prev = previousMileage {
                kmDriven = current.value - prev.value
            } else {
                kmDriven = 0
            }
            
            let economy = usage.liters > 0 ? Double(kmDriven) / usage.liters : .zero
            
            previews.append(
                FuelUsagePreviewUiModel(
                    date: usage.date,
                    liters: usage.liters,
                    cost: usage.cost,
                    economy: economy
                )
            )
        }
        return previews
    }

    func latestMaintenancePreviews() -> [MaintenancePreviewUiModel] {
        return self.maintenances
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
