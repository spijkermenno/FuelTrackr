//
//  OnboardingVehicleNameView.swift
//  FuelTrackr
//
//  Step 5: Vehicle name input
//

import SwiftUI

public struct OnboardingVehicleNameView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    private var defaultVehicleName: String {
        NSLocalizedString("onboarding_vehicle_name_default", comment: "My Car")
    }
    
    public var body: some View {
        VStack {
            // Header
            OnboardingHeader(
                title: NSLocalizedString("onboarding_vehicle_name_title", comment: "Vehicle Name"),
                description: NSLocalizedString("onboarding_vehicle_name_description", comment: "Give your vehicle a name to easily identify it.")
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Input Field
            VStack(spacing: 16) {
                TextField(
                    NSLocalizedString("onboarding_vehicle_name_placeholder", comment: "Enter vehicle name"),
                    text: $viewModel.vehicleName
                )
                .font(.system(size: 17, weight: .regular))
                .textInputAutocapitalization(.words)
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
            }
            
            Spacer()
            
            // Action Buttons - 24pt above progress bar
            VStack(spacing: 16) {
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
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!viewModel.canProceedFromCurrentStep())
                
                Button(action: {
                    viewModel.vehicleName = defaultVehicleName
                    isTextFieldFocused = false
                    // Auto-advance after setting the default name
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.nextStep()
                        }
                    }
                }) {
                    Text(String(format: NSLocalizedString("onboarding_vehicle_name_use_default", comment: "Use \"%@\""), defaultVehicleName))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(OnboardingColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.clear)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Dismiss keyboard when tapping outside input field
            isTextFieldFocused = false
        }
    }
}
