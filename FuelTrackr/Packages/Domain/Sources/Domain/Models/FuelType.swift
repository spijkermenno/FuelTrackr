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
    public var localizedName: String {
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
    
    // MARK: - Consumption Calculation
    /// Calculates consumption based on fuel type
    /// - Parameters:
    ///   - distance: Distance traveled (always in km)
    ///   - fuelAmount: Amount of fuel used (always in liters/kWh/kg)
    ///   - isUsingMetric: Whether to use metric or imperial units
    /// - Returns: Consumption value in the appropriate unit for the fuel type
    public func calculateConsumption(distance: Double, fuelAmount: Double, isUsingMetric: Bool) -> Double? {
        guard fuelAmount > 0, distance > 0 else { return nil }
        
        switch (self, isUsingMetric) {
        case (.liquid, true):
            // km/L: distance / fuel
            return distance / fuelAmount
        case (.liquid, false):
            // mpg: convert km to miles, liters to gallons, then miles / gallons
            let miles = distance * 0.621371
            let gallons = fuelAmount * 0.264172
            return gallons > 0 ? miles / gallons : nil
        case (.electric, true):
            // kWh/100km: (fuel / distance) * 100
            return (fuelAmount / distance) * 100
        case (.electric, false):
            // mi/kWh: convert km to miles, then miles / fuel
            let miles = distance * 0.621371
            return miles / fuelAmount
        case (.hydrogen, true):
            // kg H₂/100km: (fuel / distance) * 100
            return (fuelAmount / distance) * 100
        case (.hydrogen, false):
            // mi/kg H₂: convert km to miles, then miles / fuel
            let miles = distance * 0.621371
            return miles / fuelAmount
        case (.unknown, _):
            return nil
        }
    }
    
    // MARK: - Helper: Format number removing trailing .00
    private func formatNumber(_ value: Double, decimals: Int = 2) -> String {
        let formatted = String(format: "%.\(decimals)f", value)
        // Remove trailing .00 or .0
        if formatted.hasSuffix(".00") {
            return String(formatted.dropLast(3))
        } else if formatted.hasSuffix("0") && formatted.contains(".") {
            return String(formatted.dropLast())
        }
        return formatted
    }
    
    // MARK: - Consumption Formatting
    /// Formats consumption value with appropriate unit
    /// - Parameters:
    ///   - consumption: The consumption value (already calculated for the fuel type)
    ///   - isUsingMetric: Whether to use metric or imperial units
    /// - Returns: Formatted string with unit
    public func formatConsumption(_ consumption: Double, isUsingMetric: Bool) -> String {
        let unit: String
        switch (self, isUsingMetric) {
        case (.liquid, true):     unit = "km/L"
        case (.liquid, false):    unit = "mpg"
        case (.electric, true):   unit = "kWh/100km"
        case (.electric, false):  unit = "mi/kWh"
        case (.hydrogen, true):   unit = "kg H₂/100km"
        case (.hydrogen, false):  unit = "mi/kg H₂"
        case (.unknown, _):       return "-"
        }
        
        let formattedValue = formatNumber(consumption)
        return "\(formattedValue) \(unit)"
    }
    
    // MARK: - Fuel Unit Formatting
    /// Formats fuel amount with appropriate unit
    /// - Parameters:
    ///   - amount: Fuel amount (always in liters/kWh/kg)
    ///   - isUsingMetric: Whether to use metric or imperial units
    /// - Returns: Formatted string with unit
    public func formatFuelAmount(_ amount: Double, isUsingMetric: Bool) -> String {
        switch (self, isUsingMetric) {
        case (.liquid, true):
            return "\(formatNumber(amount)) L"
        case (.liquid, false):
            let gallons = amount * 0.264172
            return "\(formatNumber(gallons)) G"
        case (.electric, true):
            return "\(formatNumber(amount)) kWh"
        case (.electric, false):
            return "\(formatNumber(amount)) kWh" // kWh is universal
        case (.hydrogen, true):
            return "\(formatNumber(amount)) kg H₂"
        case (.hydrogen, false):
            return "\(formatNumber(amount)) kg H₂" // kg is universal
        case (.unknown, _):
            return formatNumber(amount)
        }
    }
    
    // MARK: - Price Unit Formatting
    /// Formats price per unit with appropriate unit
    /// - Parameters:
    ///   - price: Price per unit
    ///   - isUsingMetric: Whether to use metric or imperial units
    ///   - currency: Optional currency; when nil uses Locale.current for backwards compatibility
    /// - Returns: Formatted string with currency and unit
    public func formatPricePerUnit(_ price: Double, isUsingMetric: Bool, currency: Currency? = nil) -> String {
        let currencySymbol = currency?.symbol ?? Locale.current.currencySymbol ?? "€"
        switch (self, isUsingMetric) {
        case (.liquid, true):
            return "\(currencySymbol)\(formatNumber(price))/L"
        case (.liquid, false):
            let pricePerGallon = price * 3.78541
            return "\(currencySymbol)\(formatNumber(pricePerGallon))/G"
        case (.electric, true):
            return "\(currencySymbol)\(formatNumber(price))/kWh"
        case (.electric, false):
            return "\(currencySymbol)\(formatNumber(price))/kWh"
        case (.hydrogen, true):
            return "\(currencySymbol)\(formatNumber(price))/kg H₂"
        case (.hydrogen, false):
            return "\(currencySymbol)\(formatNumber(price))/kg H₂"
        case (.unknown, _):
            return "\(currencySymbol)\(formatNumber(price))"
        }
    }
}
