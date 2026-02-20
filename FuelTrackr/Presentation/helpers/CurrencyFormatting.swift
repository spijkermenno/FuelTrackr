//
//  CurrencyFormatting.swift
//  FuelTrackr
//
//  Created for FuelTrackr
//

import Foundation
import Domain

/// Formats monetary values using the app's selected currency.
/// Uses GetSelectedCurrencyUseCase to respect user settings instead of device locale.
public enum CurrencyFormatting {

    /// Returns a NumberFormatter configured for the given currency.
    public static func formatter(for currency: Currency) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.currencySymbol = currency.symbol
        formatter.locale = Locale(identifier: currency.parsingLocaleIdentifier)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }

    /// Formats a value using the app's selected currency.
    public static func format(_ value: Double, currency: Currency) -> String {
        formatter(for: currency).string(from: NSNumber(value: value)) ?? "\(currency.symbol)\(String(format: "%.2f", value))"
    }

    /// Formats a value using the app's selected currency (reads from settings).
    public static func format(_ value: Double) -> String {
        format(value, currency: GetSelectedCurrencyUseCase()())
    }

    /// Formats a price-per-liter value (e.g. "€1.45/L").
    public static func formatPricePerLiter(_ value: Double, currency: Currency) -> String {
        let formatted = formatter(for: currency).string(from: NSNumber(value: value))
            ?? String(format: "%.2f", value)
        return "\(formatted)/L"
    }

    /// Formats price per liter using selected currency.
    public static func formatPricePerLiter(_ value: Double) -> String {
        formatPricePerLiter(value, currency: GetSelectedCurrencyUseCase()())
    }
}
