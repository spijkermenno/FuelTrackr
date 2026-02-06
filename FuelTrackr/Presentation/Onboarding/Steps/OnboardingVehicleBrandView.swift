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
    @State private var showSelectionSheet: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    public var body: some View {
        VStack {
            OnboardingHeader(
                title: NSLocalizedString("onboarding_vehicle_brand_title", comment: "Vehicle brand"),
                description: NSLocalizedString("onboarding_vehicle_brand_question", comment: "What brand is your vehicle?")
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Input Field
            VStack(spacing: 16) {
                if isCustomBrand {
                    HStack {
                        TextField(
                            NSLocalizedString("onboarding_vehicle_brand_placeholder", comment: "Search or select your brand"),
                            text: $viewModel.vehicleBrand
                        )
                        .font(.system(size: 17, weight: .regular))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($isTextFieldFocused)
                        
                        Button(action: {
                            viewModel.vehicleBrand = ""
                            isCustomBrand = false
                            isTextFieldFocused = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(OnboardingColors.secondaryText)
                                .font(.system(size: 18))
                        }
                    }
                    .padding()
                    .background(Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark 
                            ? UIColor(OnboardingColors.darkGray)
                            : UIColor(OnboardingColors.white)
                    }))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(OnboardingColors.primaryBlue, lineWidth: 2)
                    )
                    .padding(.horizontal, 24)
                } else {
                    Button(action: {
                        showSelectionSheet = true
                    }) {
                        HStack {
                            Text(viewModel.vehicleBrand.isEmpty 
                                 ? NSLocalizedString("onboarding_vehicle_brand_placeholder", comment: "Search or select your brand")
                                 : viewModel.vehicleBrand)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(viewModel.vehicleBrand.isEmpty 
                                               ? OnboardingColors.secondaryText 
                                               : OnboardingColors.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(OnboardingColors.secondaryText)
                        }
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
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 24)
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
        .sheet(isPresented: $showSelectionSheet) {
            NativeSelectionSheet(
                items: VehicleBrands.brands,
                title: NSLocalizedString("onboarding_vehicle_brand_title", comment: "Vehicle brand"),
                customOptionText: NSLocalizedString("onboarding_not_on_list", comment: "Not on the list"),
                selectedItem: $viewModel.vehicleBrand,
                isCustomEntry: $isCustomBrand,
                isPresented: $showSelectionSheet
            )
        }
        .onChange(of: viewModel.vehicleBrand) { _ in
            if !isCustomBrand {
                viewModel.vehicleModel = ""
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    if isCustomBrand {
                        isTextFieldFocused = false
                    }
                }
        )
    }
}
