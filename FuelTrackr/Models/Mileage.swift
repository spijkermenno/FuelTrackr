//
//  Mileage.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 06/02/2025.
//

import SwiftData
import Foundation

@Model
class Mileage: Hashable {
    var value: Int
    var date: Date
    @Relationship(deleteRule: .cascade, inverse: \Vehicle.mileages) var vehicle: Vehicle?

    init(value: Int, date: Date, vehicle: Vehicle? = nil) {
        self.value = value
        self.date = date
        self.vehicle = vehicle
    }

    static func == (lhs: Mileage, rhs: Mileage) -> Bool {
        return lhs.value == rhs.value && lhs.date == rhs.date
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(date)
    }
}
