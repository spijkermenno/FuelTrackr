// MARK: - Package: Presentation
//
//  AddFuelUsageViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain
import SwiftData
import ScovilleKit
import FirebaseAnalytics
@preconcurrency import Foundation

public final class AddFuelUsageViewModel: ObservableObject {
    @Published public var liters = ""
    @Published public var cost = ""
    @Published public var mileage = ""
    @Published public var entryDate = Date()
    @Published public var errorMessage: String?
    @Published public var mileageWarning: String?
    @Published public var litersError: Bool = false
    @Published public var costError: Bool = false
    @Published public var mileageError: Bool = false
    
    private let saveFuelUsageUseCase: SaveFuelUsageUseCase
    private let getUsingMetricUseCase: GetUsingMetricUseCase
    
    public init(
        saveFuelUsageUseCase: SaveFuelUsageUseCase = SaveFuelUsageUseCase(),
        getUsingMetricUseCase: GetUsingMetricUseCase = GetUsingMetricUseCase()
    ) {
        self.saveFuelUsageUseCase = saveFuelUsageUseCase
        self.getUsingMetricUseCase = getUsingMetricUseCase
    }
    
    public var decimalSeparator: String {
        Locale(identifier: GetSelectedCurrencyUseCase()().parsingLocaleIdentifier).decimalSeparator ?? Locale.current.decimalSeparator ?? "."
    }
    
    /// Gets the previous mileage from vehicle (from latest mileage or latest fuel usage)
    private func getPreviousMileage(from vehicle: Vehicle) -> Int? {
        // Get latest mileage from mileages array
        let latestMileage = vehicle.latestMileage?.value
        
        // Get latest mileage from fuel usages
        let latestFuelMileage = vehicle.fuelUsages
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
    
    public func saveFuelUsage(activeVehicle: Vehicle?, context: ModelContext) -> Bool {
        // Clear previous errors
        errorMessage = nil
        mileageWarning = nil
        litersError = false
        costError = false
        mileageError = false
        
        // Validate all fields together
        let litersValue = parseInput(liters)
        let costValue = parseInput(cost)
        let mileageValue = Int(mileage)
        
        // Check liters validation
        if let litersVal = litersValue, litersVal > 0 {
            // Valid
        } else {
            litersError = true
        }
        
        // Check cost validation
        if let costVal = costValue, costVal >= 0 {
            // Valid
        } else {
            costError = true
        }
        
        // Check mileage format validation
        if let mileageVal = mileageValue, mileageVal > 0 {
            // Valid
        } else {
            mileageError = true
        }
        
        // If any field has an error, return false
        if litersError || costError || mileageError || activeVehicle == nil {
            return false
        }
        
        // All basic validations passed, continue with mileage comparison
        let vehicle = activeVehicle!
        let isUsingMetric = getUsingMetricUseCase()
        let adjustedMileage = isUsingMetric ? mileageValue! : convertMilesToKm(miles: mileageValue!)

        // Skip mileage validation for past entries (calculation can be off for historical data)
        let isPastEntry = !Calendar.current.isDateInToday(entryDate)
        if !isPastEntry {
            // Validate mileage against previous recorded value (only for today's entries)
            let previousMileage = getPreviousMileage(from: vehicle)
            if let previousMileage = previousMileage {
                // Check if mileage is lower than previous
                if adjustedMileage < previousMileage {
                    errorMessage = String(format: NSLocalizedString("mileage_too_low_error", comment: ""), previousMileage)
                    mileageError = true
                    return false
                }

                // Check if mileage is suspiciously high (more than 2x or more than 10,000 km/miles higher)
                let threshold = isUsingMetric ? 10000 : 6214 // ~10,000 km or ~6,214 miles
                let difference = adjustedMileage - previousMileage

                if adjustedMileage > previousMileage * 2 || difference > threshold {
                    mileageWarning = NSLocalizedString("mileage_suspiciously_high_warning", comment: "")
                    // Don't block save for warnings, just show the warning
                }
            }
        }
        
        // All validations passed, save the fuel usage
        do {
            try saveFuelUsageUseCase(
                liters: litersValue!,
                cost: costValue!,
                mileageValue: adjustedMileage,
                date: entryDate,
                context: context
            )
            
            // Capture fuel count before async task to avoid data race
            let fuelCount = vehicle.fuelUsages.count
            
            Task { @MainActor in
                let params: [String: Any] = [
                    "mileage": adjustedMileage,
                    "cost": costValue!,
                    "amount": litersValue!
                ]
                Scoville.track(FuelTrackrEvents.trackedFuel, parameters: params)
                Analytics.logEvent(FuelTrackrEvents.trackedFuel.rawValue, parameters: params)

                // Trigger review prompt based on fuel tracking count
                ReviewPrompter.shared.handleFuelTracked(trackCount: fuelCount)
            }
            
            // Clear any warnings/errors on successful save
            errorMessage = nil
            mileageWarning = nil
            litersError = false
            costError = false
            mileageError = false
            return true
        } catch {
            errorMessage = NSLocalizedString("fuel_usage_saved_error", comment: "")
            return false
        }
    }
    
    private func parseInput(_ input: String) -> Double? {
        DecimalInputParser.parse(input)
    }
    
    private func convertMilesToKm(miles: Int) -> Int {
        let kmValue = Double(miles) * 1.60934
        return Int(ceil(kmValue))
    }
    
    public func displayMileagePlaceholder(currentMileage: Int) -> String {
        if getUsingMetricUseCase() {
            return "\(currentMileage) km"
        } else {
            let miles = Int(Double(currentMileage) / 1.60934)
            return "\(miles) mi"
        }
    }
    
}
