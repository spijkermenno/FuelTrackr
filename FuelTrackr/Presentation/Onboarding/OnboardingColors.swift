//
//  OnboardingColors.swift
//  FuelTrackr
//
//  Color scheme for onboarding flow matching the design images
//  All colors from the provided design specifications
//

import SwiftUI

public struct OnboardingColors {
    // Primary Colors
    public static let primaryBlue = hexColor("#2A69D5") // Vibrant blue - 100% opacity
    public static let primaryBlue50 = hexColor("#2A69D5").opacity(0.5) // Blue - 50% opacity
    public static let primaryBlue55 = hexColor("#2A69D5").opacity(0.55) // Blue - 55% opacity
    
    // Neutral Colors
    public static let white = hexColor("#FFFFFF") // White - 100% opacity
    public static let white80 = hexColor("#FFFFFF").opacity(0.8) // White - 80% opacity
    public static let black = hexColor("#000000") // Black - 100% opacity
    public static let black25 = hexColor("#000000").opacity(0.25) // Black - 25% opacity
    public static let deepBlack = hexColor("#1C1C1C") // Deep black - 100% opacity
    public static let deepBlackAlt = hexColor("#1C1C1E") // Deep black alternate - 100% opacity
    
    // Gray Colors
    public static let darkGray = hexColor("#3A3A3D") // Very dark gray - 100% opacity
    public static let mediumGray = hexColor("#7C7C7C") // Medium gray - 100% opacity
    public static let lightGray = hexColor("#888888") // Light gray - 100% opacity
    public static let offBlack = hexColor("#2A2A2D") // Dark gray/off-black - 100% opacity
    public static let offBlack80 = hexColor("#2A2A2D").opacity(0.8) // Dark gray/off-black - 80% opacity
    
    // Background Colors
    public static let lightBackground = hexColor("#EAF0FB") // Very light, almost off-white blue - 100% opacity
    public static let lightBackgroundAlt = hexColor("#F8F8FB") // Very light gray, almost white - 100% opacity
    
    // Accent Colors
    public static let purple = hexColor("#4B2AD5") // Rich purple/indigo - 100% opacity
    public static let darkTeal = hexColor("#08202B") // Very dark teal/greenish-blue - 100% opacity
    
    // Text Colors (adapts to light/dark mode)
    public static var primaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white)
                : UIColor(deepBlack)
        })
    }
    
    public static var secondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(white80)
                : UIColor(mediumGray)
        })
    }
    
    public static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor(deepBlackAlt)
                : UIColor(lightBackground)
        })
    }
    
    // Helper function to create colors from hex
    private static func hexColor(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        guard hexSanitized.count == 6,
              let rgbValue = UInt64(hexSanitized, radix: 16) else {
            return .black
        }
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
}
