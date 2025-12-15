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

public final class AddFuelUsageViewModel: ObservableObject {
    @Published public var liters = ""
    @Published public var cost = ""
    @Published public var mileage = ""
    @Published public var errorMessage: String?
    @Published public var mileageWarning: String?
    
    private let saveFuelUsageUseCase: SaveFuelUsageUseCase
    private let getUsingMetricUseCase: GetUsingMetricUseCase
    
    // Debounce timer for mileage validation
    private var mileageValidationTask: Task<Void, Never>?
    
    public init(
        saveFuelUsageUseCase: SaveFuelUsageUseCase = SaveFuelUsageUseCase(),
        getUsingMetricUseCase: GetUsingMetricUseCase = GetUsingMetricUseCase()
    ) {
        self.saveFuelUsageUseCase = saveFuelUsageUseCase
        self.getUsingMetricUseCase = getUsingMetricUseCase
    }
    
    public var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    /// Validates mileage against previous recorded value (debounced)
    @MainActor
    public func validateMileage(against vehicle: Vehicle?) {
        mileageValidationTask?.cancel()
        
        // Capture values needed for validation before entering Task to avoid data races
        let currentMileage = mileage
        let isUsingMetric = getUsingMetricUseCase()
        
        // Capture previous mileage synchronously if vehicle exists
        let previousMileageValue: Int?
        if let vehicle = vehicle {
            previousMileageValue = getPreviousMileage(from: vehicle)
        } else {
            previousMileageValue = nil
        }
        
        mileageValidationTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
            
            guard let self = self,
                  !Task.isCancelled,
                  !currentMileage.isEmpty,
                  let mileageValue = Int(currentMileage) else {
                return
            }
            
            guard let previousMileage = previousMileageValue else {
                self.mileageWarning = nil
                return
            }
            
            let adjustedMileage = isUsingMetric ? mileageValue : self.convertMilesToKm(miles: mileageValue)
            
            // Check if mileage is lower than previous
            if adjustedMileage < previousMileage {
                self.errorMessage = String(format: NSLocalizedString("mileage_too_low_error", comment: ""), previousMileage)
                self.mileageWarning = nil
                return
            }
            
            // Check if mileage is suspiciously high (more than 2x or more than 10,000 km/miles higher)
            let threshold = isUsingMetric ? 10000 : 6214 // ~10,000 km or ~6,214 miles
            let difference = adjustedMileage - previousMileage
            
            if adjustedMileage > previousMileage * 2 || difference > threshold {
                self.mileageWarning = NSLocalizedString("mileage_suspiciously_high_warning", comment: "")
                self.errorMessage = nil
            } else {
                self.mileageWarning = nil
            }
        }
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
        guard let litersValue = parseInput(liters),
              let costValue = parseInput(cost),
              let mileageValue = Int(mileage),
              mileageValue > 0,
              let vehicle = activeVehicle else {
            errorMessage = NSLocalizedString("invalid_input_error", comment: "")
            return false
        }
        
        let adjustedMileage = getUsingMetricUseCase() ? mileageValue : convertMilesToKm(miles: mileageValue)
        
        // Validate mileage before saving
        let previousMileage = getPreviousMileage(from: vehicle)
        if let previousMileage = previousMileage, adjustedMileage < previousMileage {
            errorMessage = String(format: NSLocalizedString("mileage_too_low_error", comment: ""), previousMileage)
            return false
        }
        
        do {
            try saveFuelUsageUseCase(
                liters: litersValue,
                cost: costValue,
                mileageValue: adjustedMileage,
                context: context
            )
            
            Task { @MainActor in
                Scoville.track(
                    FuelTrackrEvents.trackedFuel,
                    parameters: [
                        "mileage": adjustedMileage,
                        "cost": costValue,
                        "amount": litersValue
                    ]
                )
            }
            
            return true
        } catch {
            errorMessage = NSLocalizedString("fuel_usage_saved_error", comment: "")
            return false
        }
    }
    
    private func parseInput(_ input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: decimalSeparator, with: ".")
        return Double(normalized)
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
    
    deinit {
        mileageValidationTask?.cancel()
    }
}
