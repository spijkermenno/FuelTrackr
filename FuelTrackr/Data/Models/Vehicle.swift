//
//  Vehicle.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import SwiftData
import Foundation

@Model
class Vehicle: Hashable {
    // MARK: - Properties
    var name: String
    var licensePlate: String
    var purchaseDate: Date
    var manufacturingDate: Date
    var photo: Data?
    var isPurchased: Bool = false
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade) var fuelUsages: [FuelUsage] = []
    @Relationship(deleteRule: .cascade) var maintenances: [Maintenance] = []
    @Relationship(deleteRule: .cascade) var mileages: [Mileage] = []

    // MARK: - Initializer
    init(
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
    var latestMileage: Mileage? {
        mileages.sorted { $0.date > $1.date }.first
    }

    // MARK: - Hashable
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.name == rhs.name &&
            lhs.licensePlate == rhs.licensePlate &&
            lhs.purchaseDate == rhs.purchaseDate &&
            lhs.manufacturingDate == rhs.manufacturingDate &&
            lhs.isPurchased == rhs.isPurchased
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(licensePlate)
        hasher.combine(purchaseDate)
        hasher.combine(manufacturingDate)
        hasher.combine(isPurchased)
    }
}
