// MARK: - Package: Presentation

//
//  Theme.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 25/04/2025.
//

import SwiftUI

public struct Theme {
    // For now, we'll use LightColors as default. Components can use @Environment(\.colorScheme) to adapt.
    // TODO: Make this dynamic based on colorScheme in the future
    public static let colors: ColorsProtocol = LightColors()
    public static let dimensions = Dimensions()
    public static let typography = Typography()
    
    // Helper to get colors for a specific color scheme
    public static func colors(for colorScheme: ColorScheme) -> ColorsProtocol {
        colorScheme == .dark ? DarkColors() : LightColors()
    }
}
