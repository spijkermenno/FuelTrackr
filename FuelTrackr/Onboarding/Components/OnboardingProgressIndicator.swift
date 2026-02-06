//
//  OnboardingProgressIndicator.swift
//  FuelTrackr
//
//  Progress indicator component for onboarding flow
//

import SwiftUI

public struct OnboardingProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    public init(currentStep: Int, totalSteps: Int) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track - light grey/blue
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(UIColor(OnboardingColors.primaryBlue)))
                    
                    // Progress fill - solid blue
                    RoundedRectangle(cornerRadius: 6)
                        .fill(OnboardingColors.background)
                        .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
                        .padding(2)
                }
            }
            .frame(height: 12)
            
            Text("\(currentStep) of \(totalSteps)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(OnboardingColors.secondaryText)
        }
        .padding(.horizontal, 24)
    }
}
