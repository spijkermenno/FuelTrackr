//
//  Vehicle.swift
//  DriveWise
//

import SwiftData
import Foundation

@Model
class Vehicle: Hashable {
    var name: String
    var licensePlate: String
    var purchaseDate: Date
    var manufacturingDate: Date
    var mileage: Int
    var photo: Data?
    
    @Relationship(deleteRule: .cascade) var fuelUsages: [FuelUsage] = []
    @Relationship(deleteRule: .cascade) var maintenances: [Maintenance] = [] // New relationship

    init(name: String, licensePlate: String, purchaseDate: Date, manufacturingDate: Date, mileage: Int, photo: Data? = nil) {
        self.name = name
        self.licensePlate = licensePlate
        self.purchaseDate = purchaseDate
        self.manufacturingDate = manufacturingDate
        self.mileage = mileage
        self.photo = photo
    }

    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.name == rhs.name &&
            lhs.licensePlate == rhs.licensePlate &&
            lhs.purchaseDate == rhs.purchaseDate &&
            lhs.manufacturingDate == rhs.manufacturingDate &&
            lhs.mileage == rhs.mileage
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(licensePlate)
        hasher.combine(purchaseDate)
        hasher.combine(manufacturingDate)
        hasher.combine(mileage)
    }
}
