//
//  AddFuelUsageViewModel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI

class AddFuelUsageViewModel: ObservableObject {
    @Published var liters = ""
    @Published var cost = ""
    @Published var mileage = ""
    @Published var errorMessage: String?

    private let saveFuelUsageUseCase: SaveFuelUsageUseCase
    private let isUsingMetric: Bool

    init(saveFuelUsageUseCase: SaveFuelUsageUseCase, isUsingMetric: Bool) {
        self.saveFuelUsageUseCase = saveFuelUsageUseCase
        self.isUsingMetric = isUsingMetric
    }

    var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    func saveFuelUsage(activeVehicle: Vehicle?) -> Bool {
        guard let litersValue = parseInput(liters),
              let costValue = parseInput(cost),
              let mileageValue = Int(mileage),
              mileageValue > 0,
              let vehicle = activeVehicle else {
            errorMessage = NSLocalizedString("invalid_input_error", comment: "")
            return false
        }
        
        let adjustedMileage = isUsingMetric ? mileageValue : convertMilesToKm(miles: mileageValue)

        do {
            try saveFuelUsageUseCase.execute(liters: litersValue, cost: costValue, mileageValue: adjustedMileage)
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
    
    func displayMileagePlaceholder(currentMileage: Int) -> String {
        if isUsingMetric {
            return "\(currentMileage) km"
        } else {
            let miles = Int(Double(currentMileage) / 1.60934)
            return "\(miles) mi"
        }
    }
}
