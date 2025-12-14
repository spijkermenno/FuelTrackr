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
    @State private var showSelectionSheet: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var availableModels: [String] {
        guard !viewModel.vehicleBrand.isEmpty else {
            return []
        }
        return VehicleModels.getModels(for: viewModel.vehicleBrand)
    }
    
    public var body: some View {
        VStack {
            OnboardingHeader(
                title: NSLocalizedString("onboarding_vehicle_model_title", comment: "Vehicle model"),
                description: NSLocalizedString("onboarding_vehicle_model_question", comment: "Which model do you drive?")
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Input Field
            VStack(spacing: 16) {
                if isCustomModel || availableModels.isEmpty {
                    HStack {
                        TextField(
                            NSLocalizedString("onboarding_vehicle_model_placeholder", comment: "Search or type your model"),
                            text: $viewModel.vehicleModel
                        )
                        .font(.system(size: 17, weight: .regular))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($isTextFieldFocused)
                        
                        if isCustomModel {
                            Button(action: {
                                viewModel.vehicleModel = ""
                                isCustomModel = false
                                isTextFieldFocused = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(OnboardingColors.secondaryText)
                                    .font(.system(size: 18))
                            }
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
                            .stroke(isCustomModel ? OnboardingColors.primaryBlue : OnboardingColors.primaryBlue.opacity(0.3), lineWidth: isCustomModel ? 2 : 1)
                    )
                    .padding(.horizontal, 24)
                } else {
                    Button(action: {
                        showSelectionSheet = true
                    }) {
                        HStack {
                            Text(viewModel.vehicleModel.isEmpty 
                                 ? NSLocalizedString("onboarding_vehicle_model_placeholder", comment: "Search or type your model")
                                 : viewModel.vehicleModel)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(viewModel.vehicleModel.isEmpty 
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
                items: availableModels,
                title: NSLocalizedString("onboarding_vehicle_model_title", comment: "Vehicle model"),
                customOptionText: NSLocalizedString("onboarding_not_on_list", comment: "Not on the list"),
                selectedItem: $viewModel.vehicleModel,
                isCustomEntry: $isCustomModel,
                isPresented: $showSelectionSheet
            )
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    if isCustomModel {
                        isTextFieldFocused = false
                    }
                }
        )
    }
}
