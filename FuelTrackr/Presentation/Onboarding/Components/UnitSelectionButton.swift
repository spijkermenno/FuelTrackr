//
//  UnitSelectionButton.swift
//  FuelTrackr
//
//  Button component for unit selection in onboarding flow
//

import SwiftUI

public struct UnitSelectionButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    public init(
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isSelected ? OnboardingColors.white : OnboardingColors.primaryBlue)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(isSelected ? OnboardingColors.white : OnboardingColors.primaryBlue)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(isSelected ? OnboardingColors.primaryBlue : OnboardingColors.background)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(OnboardingColors.primaryBlue, lineWidth: isSelected ? 0 : 2)
            )
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
