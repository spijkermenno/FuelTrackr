// MARK: - Package: Presentation
//
//  Colors.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import SwiftUI

public struct LightColors: Sendable, ColorsProtocol {
    public let primary = hexColor("#2A69D5") // Primary brand purple
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
    
    // New accent colors for fuel summary pills
    public let accentBlue = hexColor("#5AC8FA") // Light blue for distance
    public let accentBlueLight = hexColor("#5AC8FA").opacity(0.20) // 20% opacity
    public let accentGreen = hexColor("#00C864") // Green for average price
    public let accentGreenLight = hexColor("#DDF2E3") // Light green background for pills
    public let accentRed = hexColor("#E63946") // Red for fuel amount
    public let accentRedLight = hexColor("#EAE3F7") // Light purple/pink background for pills
    public let accentOrange = hexColor("#FFB400") // Orange for costs
    public let accentOrangeLight = hexColor("#F7E5C8") // Light orange/yellow background for pills
    public let accentGrey = hexColor("#3E3E41") // Dark grey for consumption/range pills
    public let fuelUsagePillBackground = hexColor("#CFFAFE") // Very light cyan for fuel usage per km pill
    public let fuelUsagePillText = hexColor("#5AC8FA") // Light blue text for fuel usage per km pill
    public let kmDrivenPillBackground = hexColor("#DBEAFE") // Light periwinkle for km driven pill
    public let kmDrivenPillText = hexColor("#1E40AF") // Medium blue text for km driven pill
    public let border = hexColor("#D6D6F6") // Border color for carousel items
    public let divider = hexColor("#EDF0F2") // Divider color between entries
}

public struct DarkColors: Sendable, ColorsProtocol {
    public let primary = hexColor("#2A69D5") // Primary blue for buttons and dates
    public let secondary = hexColor("#977EFF") // Accent purple
    public let background = hexColor("#1C1C1E") // Dark background for screens
    public let surface = hexColor("#2A2A2D") // Dark cards, sheets, etc.
    public let onPrimary = hexColor("#FFFFFF") // White text on primary background
    public let onBackground = hexColor("#FFFFFF") // White text on dark background
    public let onSurface = hexColor("#B0B0B0") // Light gray for labels
    public let success = hexColor("#2ECC71") // Success green
    public let error = hexColor("#E74C3C") // Error red
    public let purple = hexColor("#5832DF") // Alternate purple accent
    public let transparent: Color = .clear
    
    // New accent colors for fuel summary pills (dark mode)
    public let accentBlue = hexColor("#5AC8FA") // Light blue for distance
    public let accentBlueLight = hexColor("#5AC8FA").opacity(0.20) // 20% opacity
    public let accentGreen = hexColor("#00C864") // Green for average price
    public let accentGreenLight = hexColor("#00C864").opacity(0.20) // 20% opacity
    public let accentRed = hexColor("#E63946") // Red for fuel amount
    public let accentRedLight = hexColor("#E63946").opacity(0.251) // 25.1% opacity
    public let accentOrange = hexColor("#FFB400") // Orange for costs
    public let accentOrangeLight = hexColor("#FFB400").opacity(0.20) // 20% opacity
    public let accentGrey = hexColor("#3E3E41") // Dark grey for consumption/range pills
    public let fuelUsagePillBackground = hexColor("#CFFAFE") // Very light cyan for fuel usage per km pill
    public let fuelUsagePillText = hexColor("#5AC8FA") // Light blue text for fuel usage per km pill
    public let kmDrivenPillBackground = hexColor("#DBEAFE") // Light periwinkle for km driven pill
    public let kmDrivenPillText = hexColor("#1E40AF") // Medium blue text for km driven pill
    public let border = hexColor("#2D2D2D") // Border color for carousel items (dark mode)
    public let divider = hexColor("#3E3E41") // Divider color between entries
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
    var accentBlue: Color { get }
    var accentBlueLight: Color { get }
    var accentGreen: Color { get }
    var accentGreenLight: Color { get }
    var accentRed: Color { get }
    var accentRedLight: Color { get }
    var accentOrange: Color { get }
    var accentOrangeLight: Color { get }
    var accentGrey: Color { get }
    var fuelUsagePillBackground: Color { get }
    var fuelUsagePillText: Color { get }
    var kmDrivenPillBackground: Color { get }
    var kmDrivenPillText: Color { get }
    var border: Color { get }
    var divider: Color { get }
}

public func hexColor(_ hex: String, fallback: Color = .black) -> Color {
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

