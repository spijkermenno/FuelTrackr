//
//  DecimalInputParser.swift
//  FuelTrackr
//
//  Parses user input for costs and amounts (e.g. liters) supporting both
//  . and , as decimal separators based on currency convention.
//  EUR/GBP/CHF: comma as decimal (1,50); USD/CAD/AUD/JPY: dot as decimal (1.50).
//

import Foundation
import Domain

public enum DecimalInputParser {

    /// Parses a decimal input string (cost, liters, etc.) using currency-aware conventions.
    /// Accepts both . and , as decimal separator based on the currency.
    /// Returns nil if input cannot be parsed.
    public static func parse(_ input: String, currency: Currency) -> Double? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let locale = Locale(identifier: currency.parsingLocaleIdentifier)
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = locale.decimalSeparator ?? "."
        formatter.groupingSeparator = locale.groupingSeparator

        if let number = formatter.number(from: trimmed) {
            return number.doubleValue
        }

        // Fallback: try normalizing by treating last separator as decimal
        let lastDot = trimmed.lastIndex(of: ".")
        let lastComma = trimmed.lastIndex(of: ",")
        let lastSep: Character? = [lastDot, lastComma]
            .compactMap { $0 }
            .max(by: { trimmed.distance(from: trimmed.startIndex, to: $0) < trimmed.distance(from: trimmed.startIndex, to: $1) })
            .map { trimmed[$0] }

        var normalized = trimmed
        if let last = lastSep {
            let otherSep: Character = last == "." ? "," : "."
            normalized = normalized
                .replacingOccurrences(of: String(otherSep), with: "")
                .replacingOccurrences(of: String(last), with: ".")
        } else {
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        }
        return Double(normalized)
    }

    /// Parses using the app's selected currency.
    public static func parse(_ input: String) -> Double? {
        parse(input, currency: GetSelectedCurrencyUseCase()())
    }
}
