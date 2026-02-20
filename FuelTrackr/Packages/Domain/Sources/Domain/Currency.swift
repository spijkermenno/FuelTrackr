// MARK: - Package: Domain

//
//  Currency.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

public enum Currency: String, CaseIterable, Codable {
    case euro = "EUR"
    case usd = "USD"
    case gbp = "GBP"
    case jpy = "JPY"
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"

    public var symbol: String {
        switch self {
        case .euro: return "€"
        case .usd: return "$"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .aud: return "A$"
        case .cad: return "C$"
        case .chf: return "CHF"
        }
    }

    public var displayName: String {
        switch self {
        case .euro: return "Euro (€)"
        case .usd: return "US Dollar ($)"
        case .gbp: return "British Pound (£)"
        case .jpy: return "Japanese Yen (¥)"
        case .aud: return "Australian Dollar (A$)"
        case .cad: return "Canadian Dollar (C$)"
        case .chf: return "Swiss Franc (CHF)"
        }
    }

    /// Locale identifier used for parsing decimal input (e.g. cost, liters).
    /// EUR/GBP/CHF use comma as decimal separator; USD/CAD/AUD/JPY use dot.
    public var parsingLocaleIdentifier: String {
        switch self {
        case .euro, .gbp, .chf: return "de_DE"
        case .usd: return "en_US"
        case .jpy: return "ja_JP"
        case .aud: return "en_AU"
        case .cad: return "en_CA"
        }
    }
}
