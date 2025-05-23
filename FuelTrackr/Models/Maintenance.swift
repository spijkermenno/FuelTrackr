//
//  Maintenance.swift
//  FuelTrackr
//

import SwiftData
import Foundation

@Model
class Maintenance: Hashable {
    var type: MaintenanceType
    var cost: Double
    var date: Date
    var notes: String?
    @Relationship(deleteRule: .nullify) var mileage: Mileage?
    @Relationship(deleteRule: .cascade, inverse: \Vehicle.maintenances) var vehicle: Vehicle?

    init(type: MaintenanceType, cost: Double, date: Date, mileage: Mileage? = nil, notes: String? = nil, vehicle: Vehicle? = nil) {
        self.type = type
        self.cost = cost
        self.date = date
        self.notes = notes
        self.mileage = mileage
        self.vehicle = vehicle
    }

    static func == (lhs: Maintenance, rhs: Maintenance) -> Bool {
        lhs.type == rhs.type && lhs.date == rhs.date && lhs.cost == rhs.cost
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(date)
        hasher.combine(cost)
    }
}
