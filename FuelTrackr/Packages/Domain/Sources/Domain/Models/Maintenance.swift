//
//  Maintenance.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftData
import Foundation

@Model
public class Maintenance: Hashable {
    @Attribute public var type: MaintenanceType
    @Attribute public var cost: Double
    @Attribute public var isFree: Bool
    @Attribute public var date: Date
    @Attribute public var notes: String?
    
    @Relationship(deleteRule: .nullify) public var mileage: Mileage?
    @Relationship(deleteRule: .cascade, inverse: \Vehicle.maintenances) public var vehicle: Vehicle?

    public init(
        type: MaintenanceType,
        cost: Double,
        isFree: Bool,
        date: Date,
        mileage: Mileage? = nil,
        notes: String? = nil,
        vehicle: Vehicle? = nil
    ) {
        self.type = type
        self.cost = cost
        self.isFree = isFree
        self.date = date
        self.mileage = mileage
        self.notes = notes
        self.vehicle = vehicle
    }

    public static func == (lhs: Maintenance, rhs: Maintenance) -> Bool {
        return lhs.type == rhs.type &&
            lhs.cost == rhs.cost &&
            lhs.isFree == rhs.isFree &&
            lhs.date == rhs.date &&
            lhs.vehicle == rhs.vehicle
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(cost)
        hasher.combine(isFree)
        hasher.combine(date)
    }
}
