//
//  Currency.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation

enum Currency: String, CaseIterable, Codable {
    case euro = "EUR"
    case usd = "USD"
    case gbp = "GBP"
    case jpy = "JPY"
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"

    var symbol: String {
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

    var displayName: String {
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
}
