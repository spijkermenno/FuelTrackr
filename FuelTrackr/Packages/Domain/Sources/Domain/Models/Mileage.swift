//
//  Mileage.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftData
import Foundation

@Model
public class Mileage: Hashable {
    @Attribute public var value: Int? = nil
    @Attribute public var date: Date? = nil

    // Relationship back to Vehicle (to-one): plain property without @Relationship
    public var vehicle: Vehicle? = nil

    // Inverse relationships (to-many) only on this side
    @Relationship(deleteRule: .nullify, inverse: \FuelUsage.mileage)
    public var fuelUsages: [FuelUsage]? = nil

    @Relationship(deleteRule: .nullify, inverse: \Maintenance.mileage)
    public var maintenances: [Maintenance]? = nil

    public init(value: Int, date: Date, vehicle: Vehicle? = nil) {
        self.value = value
        self.date = date
        self.vehicle = vehicle
    }

    public static func == (lhs: Mileage, rhs: Mileage) -> Bool {
        return lhs.value == rhs.value &&
            lhs.date == rhs.date &&
            lhs.vehicle == rhs.vehicle
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(date)
    }
}
