//
//  VehicleRepository.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//


protocol VehicleRepository {
    func loadActiveVehicle() throws -> Vehicle?
    func refreshActiveVehicle() throws -> Vehicle?
    func saveVehicle(vehicle: Vehicle, initialMileage: Int) throws
    func updateVehicle(vehicle: Vehicle) throws
    func deleteVehicle() throws
    func updateVehiclePurchaseStatus(isPurchased: Bool) throws
    func migrateVehicles() throws

    func saveFuelUsage(liters: Double, cost: Double, mileageValue: Int) throws
    func deleteFuelUsage(fuelUsage: FuelUsage) throws
    func resetFuelUsage() throws
    func getFuelUsed(forMonth: Int, year: Int?) -> Double
    func getFuelCost(forMonth: Int, year: Int?) -> Double
    func getKmDriven(forMonth: Int, year: Int?) -> Int
    func getAverageFuelUsage(forMonth: Int, year: Int?) -> Double

    func saveMaintenance(maintenance: Maintenance) throws
    func deleteMaintenance(maintenance: Maintenance) throws
    func resetMaintenance() throws
}