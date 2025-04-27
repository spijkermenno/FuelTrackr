//
//  FuelUsage.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//


import SwiftData
import Foundation

@Model
class FuelUsage: Hashable {
    // MARK: - Properties
    var liters: Double
    var cost: Double
    var date: Date

    // MARK: - Relationships
    @Relationship(deleteRule: .nullify) var mileage: Mileage?
    @Relationship(deleteRule: .cascade, inverse: \Vehicle.fuelUsages) var vehicle: Vehicle?

    // MARK: - Initializer
    init(liters: Double, cost: Double, date: Date, mileage: Mileage? = nil, vehicle: Vehicle? = nil) {
        self.liters = liters
        self.cost = cost
        self.date = date
        self.mileage = mileage
        self.vehicle = vehicle
    }

    // MARK: - Hashable
    static func == (lhs: FuelUsage, rhs: FuelUsage) -> Bool {
        return lhs.liters == rhs.liters &&
            lhs.cost == rhs.cost &&
            lhs.date == rhs.date &&
            lhs.vehicle == rhs.vehicle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(liters)
        hasher.combine(cost)
        hasher.combine(date)
    }
}
