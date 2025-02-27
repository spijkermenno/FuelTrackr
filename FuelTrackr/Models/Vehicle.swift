//
//  Vehicle.swift
//  FuelTrackr
//

import SwiftData
import Foundation

@Model
class Vehicle: Hashable {
    var name: String
    var licensePlate: String
    var purchaseDate: Date
    var manufacturingDate: Date
    var photo: Data?
    var isPurchased: Bool = false
    
    @Relationship(deleteRule: .cascade) var fuelUsages: [FuelUsage] = []
    @Relationship(deleteRule: .cascade) var maintenances: [Maintenance] = []
    @Relationship(deleteRule: .cascade) var mileages: [Mileage] = []

    init(name: String, licensePlate: String, purchaseDate: Date, manufacturingDate: Date, photo: Data? = nil, isPurchased: Bool? = nil) {
        self.name = name
        self.licensePlate = licensePlate
        self.purchaseDate = purchaseDate
        self.manufacturingDate = manufacturingDate
        self.photo = photo
        self.isPurchased = isPurchased ?? (purchaseDate <= Date())
    }

    var latestMileage: Mileage? {
        mileages.sorted { $0.date > $1.date }.first
    }

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
