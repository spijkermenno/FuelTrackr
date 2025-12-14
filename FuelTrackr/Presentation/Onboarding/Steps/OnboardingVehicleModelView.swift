//
//  OnboardingVehicleModelView.swift
//  FuelTrackr
//
//  Step 5: Vehicle model selection
//

import SwiftUI

public struct OnboardingVehicleModelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isCustomModel: Bool = false
    
    private var availableModels: [String] {
        guard !viewModel.vehicleBrand.isEmpty else {
            return []
        }
        return VehicleModels.getModels(for: viewModel.vehicleBrand)
    }
    
    public var body: some View {
        VStack {
            // Header
            OnboardingHeader(
                title: NSLocalizedString("onboarding_vehicle_model_title", comment: "Vehicle model"),
                description: NSLocalizedString("onboarding_vehicle_model_question", comment: "Which model do you drive?")
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Searchable Dropdown
            if !availableModels.isEmpty {
                SearchableDropdown(
                    items: availableModels,
                    placeholder: NSLocalizedString("onboarding_vehicle_model_placeholder", comment: "Search or type your model"),
                    customOptionText: NSLocalizedString("onboarding_not_on_list", comment: "Not on the list"),
                    selectedItem: $viewModel.vehicleModel,
                    isCustomEntry: $isCustomModel
                )
                .padding(.horizontal, 24)
            } else {
                // If no models available for brand, show regular text field
                TextField(
                    NSLocalizedString("onboarding_vehicle_model_placeholder", comment: "Search or type your model"),
                    text: $viewModel.vehicleModel
                )
                .font(.system(size: 17, weight: .regular))
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .padding()
                .background(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark 
                        ? UIColor(OnboardingColors.darkGray)
                        : UIColor(OnboardingColors.white)
                }))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(OnboardingColors.primaryBlue.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 24)
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
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    // Dismiss keyboard when tapping outside input field
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
    }
}
