//
//  FuelType.swift
//  Domain
//
//  Created by Menno Spijker on 30/12/2025.
//

import SwiftUI
import Foundation

public enum FuelType: String, Codable {
    case liquid
    case electric
    case hydrogen
    case unknown

    // MARK: - Localized name
    var localizedName: String {
        let key: String
        switch self {
        case .liquid:   key = "fuel_liquid"
        case .electric: key = "fuel_electric"
        case .hydrogen: key = "fuel_hydrogen"
        case .unknown:  key = "fuel_unknown"
        }
        return NSLocalizedString(key, comment: "Fuel type name")
    }

    // MARK: - Formatted usage
    func formattedUsage(_ value: Double, isUsingMetric: Bool) -> String {
        let unit: String
        switch (self, isUsingMetric) {
        case (.liquid, true):     unit = "km/L"
        case (.liquid, false):    unit = "mpg"
        case (.electric, true):   unit = "kWh/100km"
        case (.electric, false):  unit = "mi/kWh"
        case (.hydrogen, true):   unit = "kg H₂/100km"
        case (.hydrogen, false):  unit = "mi/kg H₂"
        case (.unknown, _):       unit = "-"
        }

        let formattedValue = String(format: "%.1f", value)
        return "\(formattedValue) \(unit)"
    }
}
