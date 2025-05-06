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

public final class AddFuelUsageViewModel: ObservableObject {
    @Published public var liters = ""
    @Published public var cost = ""
    @Published public var mileage = ""
    @Published public var errorMessage: String?

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
        Locale.current.decimalSeparator ?? "."
    }

    public func saveFuelUsage(activeVehicle: Vehicle?, context: ModelContext) -> Bool {
        guard let litersValue = parseInput(liters),
              let costValue = parseInput(cost),
              let mileageValue = Int(mileage),
              mileageValue > 0,
              activeVehicle != nil else {
            errorMessage = NSLocalizedString("invalid_input_error", comment: "")
            return false
        }

        let adjustedMileage = getUsingMetricUseCase() ? mileageValue : convertMilesToKm(miles: mileageValue)

        do {
            try saveFuelUsageUseCase(
                liters: litersValue,
                cost: costValue,
                mileageValue: adjustedMileage,
                context: context
            )
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
}
