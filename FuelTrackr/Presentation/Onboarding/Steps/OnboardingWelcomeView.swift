//
//  OnboardingWelcomeView.swift
//  FuelTrackr
//
//  Step 1: Welcome screen with app introduction
//

import SwiftUI

public struct OnboardingWelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isAnimating = false
    
    public var body: some View {
        VStack {
            // Title and Description
            OnboardingHeader(
                title: NSLocalizedString("onboarding_welcome_title", comment: "Welcome to FuelTrackr"),
                description: NSLocalizedString("onboarding_welcome_description", comment: "Let's set up your vehicle so you can easily track your fuel usage and maintenance."),
                spacing: 16
            )
            .padding(.top, 116)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            
            Spacer()
            
            // App Icon - Safely loads app icon with iOS 26 compatibility
            // Based on: https://www.simplykyra.com/blog/how-to-safely-display-your-app-icon-in-app-ios-macos-pre-26-and-26/
            AppIconView()
                .frame(width: 120, height: 120)
                .cornerRadius(28)
                .shadow(color: OnboardingColors.black25, radius: 10, x: 0, y: 5)
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.nextStep()
                }
            }) {
                Text(NSLocalizedString("onboarding_setup_vehicle_button", comment: "Set up my vehicle"))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(OnboardingColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(OnboardingColors.primaryBlue)
                    .cornerRadius(16)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                isAnimating = true
            }
        }
    }
}
