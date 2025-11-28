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
    @Published public var errorMessage: String?

    private let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = .current
        f.decimalSeparator = Locale.current.decimalSeparator
        return f
    }()

    public init() {}

    public func load(from fuelUsage: FuelUsage, usingMetric: Bool) {
        liters = String(fuelUsage.liters)
        cost = String(fuelUsage.cost)
        mileage = String(fuelUsage.mileage?.value ?? 0)
    }

    public func validate() -> (liters: Double, cost: Double, mileageValue: Int)? {
        guard let litersVal = Double(liters.replacingOccurrences(of: ",", with: ".")), litersVal > 0 else {
            errorMessage = NSLocalizedString("validation_liters_invalid", comment: "")
            return nil
        }
        guard let costVal = Double(cost.replacingOccurrences(of: ",", with: ".")), costVal >= 0 else {
            errorMessage = NSLocalizedString("validation_cost_invalid", comment: "")
            return nil
        }
        guard let mileageVal = Int(mileage), mileageVal >= 0 else {
            errorMessage = NSLocalizedString("validation_mileage_invalid", comment: "")
            return nil
        }
        errorMessage = nil
        return (litersVal, costVal, mileageVal)
    }

    public func displayMileagePlaceholder(currentMileage: Int) -> String {
        // Match your Add VM behavior
        String(format: NSLocalizedString("mileage_placeholder_format", comment: ""), currentMileage)
    }
}
