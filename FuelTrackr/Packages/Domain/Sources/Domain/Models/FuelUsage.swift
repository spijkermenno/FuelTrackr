//
//  FuelUsage.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftData
import Foundation

@Model
public class FuelUsage: Hashable {
    // MARK: - Properties
    @Attribute public var liters: Double? = nil
    @Attribute public var cost: Double? = nil
    @Attribute public var date: Date? = nil

    // To-one relationships: plain properties without @Relationship
    public var mileage: Mileage? = nil
    public var vehicle: Vehicle? = nil

    public init(
        liters: Double,
        cost: Double,
        date: Date,
        mileage: Mileage? = nil,
        vehicle: Vehicle? = nil
    ) {
        self.liters = liters
        self.cost = cost
        self.date = date
        self.mileage = mileage
        self.vehicle = vehicle
    }

    public static func == (lhs: FuelUsage, rhs: FuelUsage) -> Bool {
        return lhs.liters == rhs.liters &&
            lhs.cost == rhs.cost &&
            lhs.date == rhs.date &&
            lhs.vehicle == rhs.vehicle
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(liters)
        hasher.combine(cost)
        hasher.combine(date)
    }
}
