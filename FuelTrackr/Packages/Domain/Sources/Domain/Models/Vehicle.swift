//
//  Vehicle.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import SwiftData
import Foundation

@Model
public class Vehicle: Hashable {
    // MARK: - Properties
    @Attribute public var name: String? = nil
    @Attribute public var licensePlate: String? = nil
    @Attribute public var purchaseDate: Date? = nil
    @Attribute public var manufacturingDate: Date? = nil
    @Attribute public var photo: Data? = nil
    @Attribute public var isPurchased: Bool? = nil

    // MARK: - Relationships
    // Keep @Relationship only on the to-many side.
    @Relationship(deleteRule: .cascade, inverse: \FuelUsage.vehicle)
    public var fuelUsages: [FuelUsage]? = nil

    @Relationship(deleteRule: .cascade, inverse: \Maintenance.vehicle)
    public var maintenances: [Maintenance]? = nil

    @Relationship(deleteRule: .cascade, inverse: \Mileage.vehicle)
    public var mileages: [Mileage]? = nil

    // MARK: - Initializer
    public init(
        name: String,
        licensePlate: String,
        purchaseDate: Date,
        manufacturingDate: Date,
        photo: Data? = nil,
        isPurchased: Bool? = nil
    ) {
        self.name = name
        self.licensePlate = licensePlate
        self.purchaseDate = purchaseDate
        self.manufacturingDate = manufacturingDate
        self.photo = photo
        self.isPurchased = isPurchased ?? (purchaseDate <= Date())
    }

    // MARK: - Computed Properties
    public var latestMileage: Mileage? {
        // Default to empty array if nil
        let allMileages = mileages ?? []
        return allMileages
            .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
            .first
    }

    // MARK: - Hashable
    public static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.name == rhs.name &&
            lhs.licensePlate == rhs.licensePlate &&
            lhs.purchaseDate == rhs.purchaseDate &&
            lhs.manufacturingDate == rhs.manufacturingDate &&
            lhs.isPurchased == rhs.isPurchased
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(licensePlate)
        hasher.combine(purchaseDate)
        hasher.combine(manufacturingDate)
        hasher.combine(isPurchased)
    }
}
