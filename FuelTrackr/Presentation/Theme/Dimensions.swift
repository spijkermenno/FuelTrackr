// MARK: - Package: Presentation

//
//  Dimensions.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 26/04/2025.
//

import SwiftUI

public struct Dimensions: Sendable {
    // MARK: - Spacing
    public let spacingXS: CGFloat = 4    // Extra Small
    public let spacingS: CGFloat = 8     // Small
    public let spacingM: CGFloat = 12    // Medium
    public let spacingL: CGFloat = 16    // Large
    public let spacingXL: CGFloat = 20   // Extra Large
    public let spacingXXL: CGFloat = 24  // Double Extra Large
    public let spacingSection: CGFloat = 32 // Section padding

    // MARK: - Corner Radius
    public let radiusCard: CGFloat = 20
    public let radiusButton: CGFloat = 12

    // MARK: - Circles (Icons/Avatars)
    public let circleS: CGFloat = 42
    public let circleM: CGFloat = 50

    // MARK: - Heights
    public let heightCardS: CGFloat = 130
    public let heightCardM: CGFloat = 260
    public let heightCardL: CGFloat = 290
}
