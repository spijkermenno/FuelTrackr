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
    @Attribute public var name: String
    @Attribute public var licensePlate: String
    @Attribute public var purchaseDate: Date
    @Attribute public var manufacturingDate: Date
    @Attribute public var photo: Data?
    @Attribute public var isPurchased: Bool? = nil

    // MARK: - Relationships
    @Relationship(deleteRule: .cascade) public var fuelUsages: [FuelUsage] = []
    @Relationship(deleteRule: .cascade) public var maintenances: [Maintenance] = []
    @Relationship(deleteRule: .cascade) public var mileages: [Mileage] = []

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
        mileages.sorted { $0.date > $1.date }.first
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
