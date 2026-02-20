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
        let isPartialFill: Bool
        let isPartialFillManuallySet: Bool
        let mileage: MileageDTO?
    }

    private struct MaintenanceDTO: Codable {
        let date: Date
        let type: MaintenanceType
        let cost: Double
        let notes: String?
        let isFree: Bool
        let mileage: MileageDTO?
    }

    private struct VehicleDTO: Codable {
        let name: String
        let fuelType: FuelType?
        let purchaseDate: Date
        let manufacturingDate: Date
        let photo: String?
        let isPurchased: Bool?
        let mileages: [MileageDTO]
        let fuelUsages: [FuelUsageDTO]
        let maintenances: [MaintenanceDTO]
    }

    private struct AppDataDTO: Codable {
        let exportedAt: Date
        let vehicles: [VehicleDTO]
    }

    /// Exports a single vehicle to JSON
    func export(_ vehicle: Vehicle) throws -> String {
        let dto = buildVehicleDTO(from: vehicle)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(dto)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "VehicleJSONExporter", code: -1, userInfo: nil)
        }
        return json
    }

    /// Exports all vehicles (entire app data) to JSON
    func exportAll(_ vehicles: [Vehicle]) throws -> String {
        let dtos = vehicles.map { buildVehicleDTO(from: $0) }
        let appData = AppDataDTO(exportedAt: Date(), vehicles: dtos)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(appData)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "VehicleJSONExporter", code: -1, userInfo: nil)
        }
        return json
    }

    private func buildVehicleDTO(from vehicle: Vehicle) -> VehicleDTO {
        VehicleDTO(
            name: vehicle.name,
            fuelType: vehicle.fuelType,
            purchaseDate: vehicle.purchaseDate,
            manufacturingDate: vehicle.manufacturingDate,
            photo: vehicle.photo.map { $0.base64EncodedString() },
            isPurchased: vehicle.isPurchased,
            mileages: vehicle.mileages.map { MileageDTO(date: $0.date, value: $0.value) },
            fuelUsages: vehicle.fuelUsages.map {
                FuelUsageDTO(
                    date: $0.date,
                    liters: $0.liters,
                    cost: $0.cost,
                    isPartialFill: $0.isPartialFill,
                    isPartialFillManuallySet: $0.isPartialFillManuallySet,
                    mileage: $0.mileage.map { MileageDTO(date: $0.date, value: $0.value) }
                )
            },
            maintenances: vehicle.maintenances.map {
                MaintenanceDTO(
                    date: $0.date,
                    type: $0.type,
                    cost: $0.cost,
                    notes: $0.notes,
                    isFree: $0.isFree,
                    mileage: $0.mileage.map { MileageDTO(date: $0.date, value: $0.value) }
                )
            }
        )
    }
}
