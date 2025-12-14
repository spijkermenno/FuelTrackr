//
//  OnboardingLicensePlateView.swift
//  FuelTrackr
//
//  Step 3: License plate input
//

import SwiftUI

public struct OnboardingLicensePlateView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    public var body: some View {
        VStack {
            // Header
            OnboardingHeader(
                title: NSLocalizedString("onboarding_license_plate_title", comment: "License plate"),
                description: NSLocalizedString("onboarding_license_plate_description", comment: "Enter your vehicle's license plate to automatically fetch public specs.")
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Input Field
            VStack(spacing: 16) {
                TextField(
                    NSLocalizedString("onboarding_license_plate_placeholder", comment: "Fill in license plate"),
                    text: $viewModel.licensePlate
                )
                .font(.system(size: 17, weight: .regular))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isTextFieldFocused)
                .padding()
                .background(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark 
                        ? UIColor(OnboardingColors.darkGray)
                        : UIColor(OnboardingColors.white)
                }))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isTextFieldFocused ? OnboardingColors.primaryBlue : OnboardingColors.primaryBlue.opacity(0.3), lineWidth: isTextFieldFocused ? 2 : 1)
                )
                .padding(.horizontal, 24)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isTextFieldFocused = true
                    }
                }
                
                // Info Text
                Text(NSLocalizedString("onboarding_license_plate_info", comment: "When available, FuelTrackr will use public vehicle data to pre-fill details. This only works for supported regions and plate formats."))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(OnboardingColors.lightGray)
                    .lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Action Buttons - 24pt above progress bar
            VStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.nextStep()
                    }
                }) {
                    Text(NSLocalizedString("continue", comment: "Continue"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(OnboardingColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.canProceedFromCurrentStep() ? OnboardingColors.primaryBlue : OnboardingColors.mediumGray)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!viewModel.canProceedFromCurrentStep())
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.nextStep()
                    }
                }) {
                    Text(NSLocalizedString("onboarding_add_later", comment: "I'll add this later"))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(OnboardingColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.bottom, 24)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Dismiss keyboard when tapping outside input field
            isTextFieldFocused = false
        }
    }
}
