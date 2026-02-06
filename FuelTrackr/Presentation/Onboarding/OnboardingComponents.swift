//
//  OnboardingComponents.swift
//  FuelTrackr
//
//  Shared components and styles for onboarding flow
//

import SwiftUI

// MARK: - Button Style
public struct ScaleButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
