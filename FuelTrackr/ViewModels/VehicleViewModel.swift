import SwiftUI
import SwiftData
import UIKit

class VehicleViewModel: ObservableObject {
    @Published var activeVehicle: Vehicle?
    @Published var refreshID = UUID()
    
    func loadActiveVehicle(context: ModelContext) {
        do {
            let result = try context.fetch(FetchDescriptor<Vehicle>())
            if let existingVehicle = result.first {
                if existingVehicle == activeVehicle { return }
                activeVehicle = existingVehicle
                refreshID = UUID()
            }
        } catch {
            print("Error fetching vehicles: \(error.localizedDescription)")
        }
    }

    func refresh(context: ModelContext) {
        loadActiveVehicle(context: context)
    }

    func updateVehicle(
        context: ModelContext,
        name: String,
        licensePlate: String,
        purchaseDate: Date,
        manufacturingDate: Date,
        photo: Data?,
        isPurchased: Bool
    ) {
        guard let vehicle = activeVehicle else { return }

        vehicle.name = name
        vehicle.licensePlate = licensePlate
        vehicle.purchaseDate = purchaseDate
        vehicle.manufacturingDate = manufacturingDate
        vehicle.photo = photo
        vehicle.isPurchased = isPurchased

        saveContext(context: context)
    }

    func saveVehicle(
        context: ModelContext,
        vehicleName: String,
        licensePlate: String,
        purchaseDate: Date,
        manufacturingDate: Date,
        initialMileage: Int,
        image: UIImage?
    ) -> Bool {
        let newVehicle = Vehicle(
            name: vehicleName,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            photo: image?.jpegData(compressionQuality: 0.8)
        )

        // Create the initial mileage entry.
        let initialMileageEntry = Mileage(value: initialMileage, date: Date(), vehicle: newVehicle)

        // Explicitly insert the mileage entry into the context.
        context.insert(initialMileageEntry)

        // Ensure the relationship is established before inserting the vehicle.
        newVehicle.mileages.append(initialMileageEntry)

        // Insert the vehicle into the context after all properties are set.
        context.insert(newVehicle)

        do {
            print("Before Save: \(newVehicle.mileages)")
            try context.save()
            print("After Save: \(activeVehicle?.mileages ?? [])")

            activeVehicle = newVehicle

            return true
        } catch {
            print("Error saving vehicle: \(error.localizedDescription)")
            return false
        }
    }

    func deleteActiveVehicle(context: ModelContext) {
        print("Deleting vehicle started")

        guard let vehicle = activeVehicle else {
            print("No active vehicle to delete")
            return
        }

        print("Vehicle found: \(vehicle)")

        // Remove relationships manually (if needed)
        do {
            try context.delete(model: Mileage.self)
            try context.delete(model: FuelUsage.self)
            try context.delete(model: Maintenance.self)
            
            print("Deleted related records")

            // Nullify the reference before deletion to prevent EXC_BAD_ACCESS
            activeVehicle = nil

            print("Deleting vehicle...")
            try context.delete(model: Vehicle.self)
            
            print("Saving context...")
            try context.save()
            print("Vehicle successfully deleted")
        } catch {
            print("Error deleting active vehicle: \(error.localizedDescription)")
        }
    }

    func saveFuelUsage(context: ModelContext, liters: Double, cost: Double, mileageValue: Int) -> Bool {
        guard let vehicle = activeVehicle else { return false }
        
        let mileage = getOrCreateMileage(context: context, mileageValue: mileageValue)
        
        let newFuelUsage = FuelUsage(
            liters: liters,
            cost: cost,
            date: Date(),
            mileage: mileage,
            vehicle: vehicle
        )

        vehicle.fuelUsages.append(newFuelUsage)
        
        let result = saveContext(context: context)
        loadActiveVehicle(context: context)
        
        return result
    }

    func saveMaintenance(
        context: ModelContext,
        maintenanceType: MaintenanceType,
        cost: Double,
        isFree: Bool,
        date: Date,
        mileageValue: Int,
        notes: String?
    ) -> Bool {
        guard let vehicle = activeVehicle else { return false }
        
        let newMaintenance = Maintenance(
            type: maintenanceType,
            cost: cost,
            isFree: isFree,
            date: date,
            mileage: Mileage(value: mileageValue, date: date, vehicle: nil),
            notes: notes,
            vehicle: vehicle
        )

        vehicle.maintenances.append(newMaintenance)

        let result = saveContext(context: context)
        loadActiveVehicle(context: context)
        
        return result
    }

    private func getOrCreateMileage(context: ModelContext, mileageValue: Int, date: Date = Date()) -> Mileage {
        guard let vehicle = activeVehicle else { fatalError("No active vehicle") }
        
        if let existingMileage = vehicle.mileages.first(where: { $0.value == mileageValue }) {
            return existingMileage
        }
        
        let newMileage = Mileage(value: mileageValue, date: date, vehicle: vehicle)
        vehicle.mileages.append(newMileage)
        return newMileage
    }

    func deleteFuelUsage(context: ModelContext, fuelUsage: FuelUsage) {
        guard let vehicle = activeVehicle else { return }
        
        if let index = vehicle.fuelUsages.firstIndex(of: fuelUsage) {
            vehicle.fuelUsages.remove(at: index)
        }

        context.delete(fuelUsage)
        
        saveContext(context: context)
    }

    func deleteMaintenance(context: ModelContext, maintenance: Maintenance) {
        guard let vehicle = activeVehicle else { return }
        
        if let index = vehicle.maintenances.firstIndex(of: maintenance) {
            vehicle.maintenances.remove(at: index)
        }

        context.delete(maintenance)
        
        saveContext(context: context)
    }

    func resetAllMaintenance(context: ModelContext) -> Bool {
        activeVehicle?.maintenances.removeAll()
        return saveContext(context: context)
    }

    func resetAllFuelUsage(context: ModelContext) -> Bool {
        activeVehicle?.fuelUsages.removeAll()
        return saveContext(context: context)
    }

    private func saveContext(context: ModelContext) -> Bool {
        do {
            try context.save()
            print("Data saved successfully.")
            return true
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
            return false
        }
    }

    func updateVehiclePurchaseStatus(isPurchased: Bool, context: ModelContext) {
        activeVehicle?.isPurchased = isPurchased
        saveContext(context: context)
    }

    func migrateVehicles(context: ModelContext) {
        let allVehicles = try? context.fetch(FetchDescriptor<Vehicle>())
        allVehicles?.forEach { vehicle in
            if vehicle.isPurchased == nil {
                vehicle.isPurchased = vehicle.purchaseDate <= Date()
            }
        }
        try? context.save()
    }
}

// MARK: - Monthly Recap with Parameterized Month

extension VehicleViewModel {
    
    /// Returns the start and end date for the given month and year.
    /// - Parameters:
    ///   - month: The month number (1 for January, 2 for February, etc.)
    ///   - year: The year to use. If not provided, the current year is used.
    /// - Returns: A tuple with the start and end Date of the month.
    private func dateRange(forMonth month: Int, year: Int? = nil) -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        let targetYear = year ?? calendar.component(.year, from: now)
        var components = DateComponents(year: targetYear, month: month, day: 1)
        guard let monthStart = calendar.date(from: components) else { return nil }
        var comps = DateComponents()
        comps.month = 1
        comps.second = -1
        guard let monthEnd = calendar.date(byAdding: comps, to: monthStart) else { return nil }
        return (start: monthStart, end: monthEnd)
    }
    
    /// Computes the total fuel used (in liters) during the specified month.
    func fuelUsed(forMonth month: Int, year: Int? = nil) -> Double {
        guard let vehicle = activeVehicle,
              let range = dateRange(forMonth: month, year: year) else { return 0 }
        let usages = vehicle.fuelUsages.filter { $0.date >= range.start && $0.date <= range.end }
        return usages.reduce(0) { $0 + $1.liters }
    }
    
    /// Computes the total fuel cost incurred during the specified month.
    func fuelCost(forMonth month: Int, year: Int? = nil) -> Double {
        guard let vehicle = activeVehicle,
              let range = dateRange(forMonth: month, year: year) else { return 0 }
        let usages = vehicle.fuelUsages.filter { $0.date >= range.start && $0.date <= range.end }
        return usages.reduce(0) { $0 + $1.cost }
    }
    
    /// Computes the kilometers driven during the specified month from mileage records.
    func kmDriven(forMonth month: Int, year: Int? = nil) -> Int {
        guard let vehicle = activeVehicle,
              let range = dateRange(forMonth: month, year: year),
              !vehicle.mileages.isEmpty else { return 0 }
        
        // Filter mileages for the specified month and sort in ascending date order.
        let mileages = vehicle.mileages.filter { $0.date >= range.start && $0.date <= range.end }
                                    .sorted(by: { $0.date < $1.date })
        guard let first = mileages.first, let last = mileages.last else { return 0 }
        return last.value - first.value
    }
    
    /// Computes the average fuel usage (km per liter) during the specified month.
    func averageFuelUsage(forMonth month: Int, year: Int? = nil) -> Double {
        let km = Double(kmDriven(forMonth: month, year: year))
        let fuelUsed = fuelUsed(forMonth: month, year: year)
        guard fuelUsed > 0 else { return 0 }
        return km / fuelUsed
    }
}
