//
//  OnboardingVehicleBrandView.swift
//  FuelTrackr
//
//  Step 4: Vehicle brand selection
//

import SwiftUI

public struct OnboardingVehicleBrandView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isCustomBrand: Bool = false
    
    public var body: some View {
        VStack {
            // Header
            OnboardingHeader(
                title: NSLocalizedString("onboarding_vehicle_brand_title", comment: "Vehicle brand"),
                description: NSLocalizedString("onboarding_vehicle_brand_question", comment: "What brand is your vehicle?")
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Searchable Dropdown
            SearchableDropdown(
                items: VehicleBrands.brands,
                placeholder: NSLocalizedString("onboarding_vehicle_brand_placeholder", comment: "Search or select your brand"),
                customOptionText: NSLocalizedString("onboarding_not_on_list", comment: "Not on the list"),
                selectedItem: $viewModel.vehicleBrand,
                isCustomEntry: $isCustomBrand
            )
            .padding(.horizontal, 24)
            .onChange(of: viewModel.vehicleBrand) { _ in
                if !isCustomBrand {
                    // Clear model when brand changes (unless it's a custom entry)
                    viewModel.vehicleModel = ""
                }
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
