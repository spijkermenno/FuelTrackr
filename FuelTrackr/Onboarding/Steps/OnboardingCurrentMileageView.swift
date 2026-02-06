//
//  OnboardingCurrentMileageView.swift
//  FuelTrackr
//
//  Step 7: Current mileage input
//

import SwiftUI

public struct OnboardingCurrentMileageView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isTextFieldFocused: Bool

    // MARK: - Placeholder

    private var mileagePlaceholder: String {
        viewModel.isUsingMetric
            ? NSLocalizedString("onboarding_mileage_placeholder_km", comment: "e.g. 125,000 km")
            : NSLocalizedString("onboarding_mileage_placeholder_miles", comment: "e.g. 77,671 mi")
    }

    // MARK: - Formatter (locale-aware)

    private var mileageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.maximumFractionDigits = 0
        return formatter
    }

    // MARK: - Formatted binding (safe for typing)

    private var mileageBinding: Binding<String> {
        Binding(
            get: {
                guard
                    !viewModel.currentMileage.isEmpty,
                    let number = Int(viewModel.currentMileage)
                else {
                    return ""
                }

                return mileageFormatter.string(
                    from: NSNumber(value: number)
                ) ?? viewModel.currentMileage
            },
            set: { newValue in
                // Keep only digits in the ViewModel
                viewModel.currentMileage = newValue.filter(\.isNumber)
            }
        )
    }

    // MARK: - View

    public var body: some View {
        VStack {
            // Header
            OnboardingHeader(
                title: NSLocalizedString(
                    "onboarding_current_mileage_title",
                    comment: "Current mileage"
                ),
                description: NSLocalizedString(
                    "onboarding_current_mileage_question",
                    comment: "What's your vehicle's current mileage?"
                )
            )
            .padding(.top, 116)

            Spacer()

            // Input Field
            VStack(spacing: 16) {
                TextField(
                    mileagePlaceholder,
                    text: mileageBinding
                )
                .font(.system(size: 17, weight: .regular))
                .keyboardType(.numberPad)
                .focused($isTextFieldFocused)
                .padding()
                .background(
                    Color(
                        UIColor { traitCollection in
                            traitCollection.userInterfaceStyle == .dark
                                ? UIColor(OnboardingColors.darkGray)
                                : UIColor(OnboardingColors.white)
                        }
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isTextFieldFocused
                                ? OnboardingColors.primaryBlue
                                : OnboardingColors.primaryBlue.opacity(0.3),
                            lineWidth: isTextFieldFocused ? 2 : 1
                        )
                )
                .padding(.horizontal, 24)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isTextFieldFocused = true
                    }
                }
            }

            Spacer()

            // Action Buttons
            VStack(spacing: 16) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.nextStep()
                    }
                } label: {
                    Text(NSLocalizedString("continue", comment: "Continue"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(OnboardingColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            viewModel.canProceedFromCurrentStep()
                                ? OnboardingColors.primaryBlue
                                : OnboardingColors.mediumGray
                        )
                        .cornerRadius(16)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(!viewModel.canProceedFromCurrentStep())
                
                Button {
                    viewModel.currentMileage = "0"
                    isTextFieldFocused = false
                    // Auto-advance after setting mileage to 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.nextStep()
                        }
                    }
                } label: {
                    Text(NSLocalizedString("onboarding_mileage_new_car", comment: "Start from 0"))
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
