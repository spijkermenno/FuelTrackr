// MARK: - Package: Domain
//
//  VehicleRepositoryProtocol.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import Foundation
import SwiftData

public protocol VehicleRepositoryProtocol {
    func loadActiveVehicle(context: ModelContext) throws -> Vehicle?
    func refreshActiveVehicle(context: ModelContext) throws -> Vehicle?
    func saveVehicle(vehicle: Vehicle, initialMileage: Int, context: ModelContext) throws
    func updateVehicle(vehicle: Vehicle, context: ModelContext) throws
    func deleteVehicle(context: ModelContext) throws
    func updateVehiclePurchaseStatus(isPurchased: Bool, context: ModelContext) throws
    func migrateVehicles(context: ModelContext) throws

    func saveFuelUsage(liters: Double, cost: Double, mileageValue: Int, date: Date, context: ModelContext) throws
    func deleteFuelUsage(fuelUsage: FuelUsage, context: ModelContext) throws
    func resetFuelUsage(context: ModelContext) throws
    func getFuelUsage(id: PersistentIdentifier, context: ModelContext) throws -> FuelUsage?
    func updateFuelUsage(id: PersistentIdentifier, liters: Double, cost: Double, mileageValue: Int, date: Date, context: ModelContext) throws
    func updateFuelUsagePartialFillStatus(id: PersistentIdentifier, isPartialFill: Bool, context: ModelContext) throws
    func getFuelUsed(forMonth: Int, year: Int?, context: ModelContext) -> Double
    func getFuelCost(forMonth: Int, year: Int?, context: ModelContext) -> Double
    func getKmDriven(forMonth: Int, year: Int?, context: ModelContext) -> Int
    func getAverageFuelUsage(forMonth: Int, year: Int?, context: ModelContext) -> Double

    func saveMaintenance(maintenance: Maintenance, context: ModelContext) throws
    func deleteMaintenance(maintenance: Maintenance, context: ModelContext) throws
    func resetMaintenance(context: ModelContext) throws
}
