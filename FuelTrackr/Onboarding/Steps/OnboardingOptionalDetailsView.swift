//
//  OnboardingOptionalDetailsView.swift
//  FuelTrackr
//
//  Step 6: Optional details (Purchase date and Production date)
//

import SwiftUI

public struct OnboardingOptionalDetailsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack {
            // Header
            OnboardingHeader(
                title: NSLocalizedString("onboarding_optional_details_title", comment: "Optional details"),
                description: NSLocalizedString("onboarding_optional_details_description", comment: "Add these to improve maintenance estimates and long term cost insights.")
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Date Input Fields
            VStack(spacing: 20) {
                DateInputField(
                    title: NSLocalizedString("purchase_date_title", comment: "Purchase date"),
                    date: $viewModel.purchaseDate,
                    placeholder: NSLocalizedString("onboarding_select_date_placeholder", comment: "Select date")
                )
                
                DateInputField(
                    title: NSLocalizedString("onboarding_production_date_title", comment: "Production month & year"),
                    date: $viewModel.productionDate,
                    placeholder: NSLocalizedString("onboarding_select_date_placeholder", comment: "Select date")
                )
            }
            .padding(.horizontal, 24)
            
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
                        .background(OnboardingColors.primaryBlue)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.nextStep()
                    }
                }) {
                    Text(NSLocalizedString("onboarding_skip_for_now", comment: "Skip for now"))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(OnboardingColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
            }
            .padding(.bottom, 24)
        }
    }
}

