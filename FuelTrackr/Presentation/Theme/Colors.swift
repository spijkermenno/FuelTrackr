// MARK: - Package: Presentation
//
//  Colors.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import SwiftUI

public struct LightColors: Sendable, ColorsProtocol {
    public let primary = hexColor("#5334D7") // Primary brand purple
    public let secondary = hexColor("#977EFF") // Accent purple
    public let background = hexColor("#F8F8FB") // Light background for screens
    public let surface = hexColor("#FFFFFF") // White cards, sheets, etc.
    public let onPrimary = hexColor("#FFFFFF") // White text on primary background
    public let onBackground = hexColor("#202124") // Dark text on light background
    public let onSurface = hexColor("#787C82") // Medium gray for labels
    public let success = hexColor("#2ECC71") // Success green
    public let error = hexColor("#E74C3C") // Error red
    public let purple = hexColor("#5832DF") // Alternate purple accent
    public let transparent: Color = .clear
}

public protocol ColorsProtocol: Sendable {
    var primary: Color { get }
    var secondary: Color { get }
    var background: Color { get }
    var surface: Color { get }
    var onPrimary: Color { get }
    var onBackground: Color { get }
    var onSurface: Color { get }
    var success: Color { get }
    var error: Color { get }
    var purple: Color { get }
    var transparent: Color { get }
}

public extension ColorsProtocol {
    static func hexColor(_ hex: String, fallback: Color = .black) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        guard hexSanitized.count == 6,
              let rgbValue = UInt64(hexSanitized, radix: 16) else {
            assertionFailure("Invalid hex color format: \(hex)")
            return fallback
        }

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255
        let blue = Double(rgbValue & 0x0000FF) / 255

        return Color(red: red, green: green, blue: blue)
    }
}
