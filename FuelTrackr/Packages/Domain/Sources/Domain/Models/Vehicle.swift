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
    
    // MARK: - JSON Representation
    public func toJSON(prettyPrinted: Bool = true) -> String? {
        struct VehicleDTO: Codable {
            let name: String
            let licensePlate: String
            let purchaseDate: Date
            let manufacturingDate: Date
            let isPurchased: Bool?
            let fuelUsages: [FuelUsageDTO]
            let maintenances: [MaintenanceDTO]
            let mileages: [MileageDTO]
        }

        struct FuelUsageDTO: Codable {
            let liters: Double
            let cost: Double
            let date: Date
            let mileage: MileageDTO?
        }

        struct MaintenanceDTO: Codable {
            let type: String
            let cost: Double
            let isFree: Bool
            let date: Date
            let notes: String?
            let mileage: MileageDTO?
        }

        struct MileageDTO: Codable {
            let value: Int
            let date: Date
        }

        // Map to DTOs
        let dto = VehicleDTO(
            name: name,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            isPurchased: isPurchased,
            fuelUsages: fuelUsages.map { fu in
                FuelUsageDTO(
                    liters: fu.liters,
                    cost: fu.cost,
                    date: fu.date,
                    mileage: fu.mileage.map { MileageDTO(value: $0.value, date: $0.date) }
                )
            },
            maintenances: maintenances.map { m in
                MaintenanceDTO(
                    type: String(describing: m.type),
                    cost: m.cost,
                    isFree: m.isFree,
                    date: m.date,
                    notes: m.notes,
                    mileage: m.mileage.map { MileageDTO(value: $0.value, date: $0.date) }
                )
            },
            mileages: mileages.map { MileageDTO(value: $0.value, date: $0.date) }
        )

        // Encode
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if prettyPrinted {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }

        return try? String(data: encoder.encode(dto), encoding: .utf8)
    }
}
