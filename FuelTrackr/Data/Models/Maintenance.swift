//
//  Maintenance.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftData
import Foundation

@Model
class Maintenance: Hashable {
    var type: MaintenanceType
    var cost: Double
    var isFree: Bool
    var date: Date
    var notes: String?
    @Relationship(deleteRule: .nullify) var mileage: Mileage?
    @Relationship(deleteRule: .cascade, inverse: \Vehicle.maintenances) var vehicle: Vehicle?

    init(type: MaintenanceType, cost: Double, isFree: Bool, date: Date, mileage: Mileage? = nil, notes: String? = nil, vehicle: Vehicle? = nil) {
        self.type = type
        self.cost = cost
        self.isFree = isFree
        self.date = date
        self.mileage = mileage
        self.notes = notes
        self.vehicle = vehicle
    }

    static func == (lhs: Maintenance, rhs: Maintenance) -> Bool {
        return lhs.type == rhs.type &&
            lhs.cost == rhs.cost &&
            lhs.isFree == rhs.isFree &&
            lhs.date == rhs.date &&
            lhs.vehicle == rhs.vehicle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(cost)
        hasher.combine(isFree)
        hasher.combine(date)
    }
}
