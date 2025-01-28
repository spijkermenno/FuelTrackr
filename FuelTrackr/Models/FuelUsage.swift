//
//  FuelUsage.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftData
import Foundation

@Model
class FuelUsage: Hashable {
    var liters: Double
    var cost: Double
    var mileage: Int
    var date: Date
    @Relationship(deleteRule: .cascade, inverse: \Vehicle.fuelUsages) var vehicle: Vehicle?

    init(liters: Double, cost: Double, mileage: Int, date: Date, vehicle: Vehicle? = nil) {
        self.liters = liters
        self.cost = cost
        self.mileage = mileage
        self.date = date
        self.vehicle = vehicle
    }

    static func == (lhs: FuelUsage, rhs: FuelUsage) -> Bool {
        return lhs.liters == rhs.liters &&
            lhs.cost == rhs.cost &&
            lhs.mileage == rhs.mileage &&
            lhs.date == rhs.date &&
            lhs.vehicle == rhs.vehicle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(liters)
        hasher.combine(cost)
        hasher.combine(mileage)
        hasher.combine(date)
    }
}
