//
//  VehicleJSONExporter.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/06/2025.
//


import Foundation
import Domain

final class VehicleJSONExporter {
    private struct MileageDTO: Codable {
        let date: Date
        let value: Int
    }

    private struct FuelUsageDTO: Codable {
        let date: Date
        let liters: Double
        let cost: Double
    }

    private struct MaintenanceDTO: Codable {
        let date: Date
        let type: MaintenanceType
        let cost: Double
        let notes: String?
        let isFree: Bool
    }

    private struct VehicleDTO: Codable {
        let name: String
        let licensePlate: String
        let purchaseDate: Date?
        let manufacturingDate: Date?
        let mileages: [MileageDTO]
        let fuelUsages: [FuelUsageDTO]
        let maintenances: [MaintenanceDTO]
    }

    func export(_ vehicle: Vehicle) throws -> String {
        let dto = VehicleDTO(
            name: vehicle.name,
            licensePlate: vehicle.licensePlate,
            purchaseDate: vehicle.purchaseDate,
            manufacturingDate: vehicle.manufacturingDate,
            mileages: vehicle.mileages.map { MileageDTO(date: $0.date, value: $0.value) },
            fuelUsages: vehicle.fuelUsages.map {
                FuelUsageDTO(date: $0.date, liters: $0.liters, cost: $0.cost)
            },
            maintenances: vehicle.maintenances.map {
                MaintenanceDTO(
                    date: $0.date,
                    type: $0.type,
                    cost: $0.cost,
                    notes: $0.notes,
                    isFree: $0.isFree
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(dto)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "VehicleJSONExporter", code: -1, userInfo: nil)
        }
        return json
    }
}
