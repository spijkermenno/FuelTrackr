//
//  EditFuelUsageViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 20/08/2025.
//

import SwiftUI
import SwiftData
import Domain

public final class EditFuelUsageViewModel: ObservableObject {
    @Published public var liters: String = ""
    @Published public var cost: String = ""
    @Published public var mileage: String = ""
    @Published public var isPartialFill: Bool = false
    @Published public var errorMessage: String?
    @Published public var litersError: Bool = false
    @Published public var costError: Bool = false
    @Published public var mileageError: Bool = false

    private let getUsingMetricUseCase: GetUsingMetricUseCase

    public init(getUsingMetricUseCase: GetUsingMetricUseCase = GetUsingMetricUseCase()) {
        self.getUsingMetricUseCase = getUsingMetricUseCase
    }

    public func load(from fuelUsage: FuelUsage, usingMetric: Bool) {
        liters = String(fuelUsage.liters)
        cost = String(fuelUsage.cost)
        mileage = String(fuelUsage.mileage?.value ?? 0)
        isPartialFill = fuelUsage.isPartialFill
    }

    public func validate(vehicle: Vehicle?, currentFuelUsageID: PersistentIdentifier?) -> (liters: Double, cost: Double, mileageValue: Int)? {
        // Clear previous errors
        errorMessage = nil
        litersError = false
        costError = false
        mileageError = false
        
        // Validate all fields together (DecimalInputParser supports both . and , as decimal separator)
        let litersVal = DecimalInputParser.parse(liters)
        let costVal = DecimalInputParser.parse(cost)
        let mileageVal = Int(mileage)
        
        // Check liters validation
        if let liters = litersVal, liters > 0 {
            // Valid
        } else {
            litersError = true
        }
        
        // Check cost validation
        if let cost = costVal, cost >= 0 {
            // Valid
        } else {
            costError = true
        }
        
        // Check mileage format validation
        if let mileage = mileageVal, mileage > 0 {
            // Valid
        } else {
            mileageError = true
        }
        
        // If any field has an error, set error message and return nil
        if litersError || costError || mileageError {
            // Set the first error message found (prioritize in order: liters, cost, mileage)
            if litersError {
                errorMessage = NSLocalizedString("validation_liters_invalid", comment: "")
            } else if costError {
                errorMessage = NSLocalizedString("validation_cost_invalid", comment: "")
            } else if mileageError {
                errorMessage = NSLocalizedString("validation_mileage_invalid", comment: "")
            }
            return nil
        }
        
        // All basic validations passed, continue with mileage comparison
        let isUsingMetric = getUsingMetricUseCase()
        let adjustedMileage = isUsingMetric ? mileageVal! : convertMilesToKm(miles: mileageVal!)
        
        // Validate mileage against previous recorded value (excluding current fuel usage)
        if let vehicle = vehicle {
            let previousMileage = getPreviousMileage(from: vehicle, excludingFuelUsageID: currentFuelUsageID)
            if let previousMileage = previousMileage, adjustedMileage < previousMileage {
                errorMessage = String(format: NSLocalizedString("mileage_too_low_error", comment: ""), previousMileage)
                mileageError = true
                return nil
            }
        }
        
        // All validations passed - return adjusted mileage (in km)
        return (litersVal!, costVal!, adjustedMileage)
    }
    
    /// Gets the previous mileage from vehicle, excluding the current fuel usage being edited
    private func getPreviousMileage(from vehicle: Vehicle, excludingFuelUsageID: PersistentIdentifier?) -> Int? {
        // Get latest mileage from mileages array
        let latestMileage = vehicle.latestMileage?.value
        
        // Get latest mileage from fuel usages, excluding the current one being edited
        let latestFuelMileage = vehicle.fuelUsages
            .filter { fuelUsage in
                if let excludingID = excludingFuelUsageID {
                    return fuelUsage.persistentModelID != excludingID
                }
                return true
            }
            .compactMap { $0.mileage?.value }
            .max()
        
        // Return the highest value between the two
        if let latestMileage = latestMileage, let latestFuelMileage = latestFuelMileage {
            return max(latestMileage, latestFuelMileage)
        } else if let latestMileage = latestMileage {
            return latestMileage
        } else if let latestFuelMileage = latestFuelMileage {
            return latestFuelMileage
        }
        
        return nil
    }
    
    private func convertMilesToKm(miles: Int) -> Int {
        let kmValue = Double(miles) * 1.60934
        return Int(ceil(kmValue))
    }

    public func displayMileagePlaceholder(currentMileage: Int) -> String {
        // Match your Add VM behavior
        String(format: NSLocalizedString("mileage_placeholder_format", comment: ""), currentMileage)
    }
}
