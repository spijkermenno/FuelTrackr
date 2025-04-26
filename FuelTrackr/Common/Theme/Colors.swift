//
//  Colors.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import SwiftUI

struct Colors {
    // MARK: - Primary Brand Color
    /// Vibrant Indigo Purple – brand-defining, bold, and energetic
    /// RGB: (83, 52, 215)
    let primary = Color(red: 83 / 255, green: 52 / 255, blue: 215 / 255)

    // MARK: - Secondary Accent Color
    /// Soft Lavender Blue – used for subtle accents, outlines, or highlights
    /// RGB: (151, 126, 255)
     let secondary = Color(red: 151 / 255, green: 126 / 255, blue: 255 / 255)

    // MARK: - Background Color
    /// Light Grayish White – clean and neutral background for light mode
    /// RGB: (248, 248, 251)
     let background = Color(red: 248 / 255, green: 248 / 255, blue: 251 / 255)

    // MARK: - Surface Color
    /// Pure White – for cards and floating components
    /// RGB: (255, 255, 255)
     let surface = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)

    // MARK: - On Primary Text
    /// White – highly readable text on purple backgrounds
    /// RGB: (255, 255, 255)
     let onPrimary = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)

    // MARK: - On Background Text
    /// Charcoal Gray – readable primary text
    /// RGB: (32, 33, 36)
     let onBackground = Color(red: 32 / 255, green: 33 / 255, blue: 36 / 255)

    // MARK: - On Surface Text
    /// Muted Gray – secondary text or captions
    /// RGB: (120, 124, 130)
     let onSurface = Color(red: 120 / 255, green: 124 / 255, blue: 130 / 255)

    // MARK: - Success Color
    /// Fresh Leaf Green – for success badges, indicators
    /// RGB: (46, 204, 113)
     let success = Color(red: 46 / 255, green: 204 / 255, blue: 113 / 255)

    // MARK: - Error Color
    /// Vivid Red – used for destructive actions or alerts
    /// RGB: (231, 76, 60)
     let error = Color(red: 231 / 255, green: 76 / 255, blue: 60 / 255)
}
