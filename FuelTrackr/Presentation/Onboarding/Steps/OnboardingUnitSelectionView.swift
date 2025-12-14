//
//  OnboardingUnitSelectionView.swift
//  FuelTrackr
//
//  Step 2: Unit selection (Metric vs Imperial)
//

import SwiftUI

public struct OnboardingUnitSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    public var body: some View {
        VStack {
            // Title and Description
            OnboardingHeader(
                title: NSLocalizedString("onboarding_unit_selection_title", comment: "Distance & Consumption"),
                description: NSLocalizedString("onboarding_unit_selection_question", comment: "Which units do you use for distance and fuel consumption?"),
                spacing: 16
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Unit Selection Buttons
            VStack(spacing: 16) {
                UnitSelectionButton(
                    title: NSLocalizedString("kilometers_liters", comment: "Kilometers & Liters"),
                    subtitle: NSLocalizedString("metric", comment: "(Metric)"),
                    isSelected: viewModel.isUsingMetric,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.updateMetricSystem(true)
                        }
                        // Auto-advance after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.nextStep()
                            }
                        }
                    }
                )
                
                UnitSelectionButton(
                    title: NSLocalizedString("miles_gallons", comment: "Miles & Gallons"),
                    subtitle: NSLocalizedString("imperial", comment: "(Imperial)"),
                    isSelected: !viewModel.isUsingMetric,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.updateMetricSystem(false)
                        }
                        // Auto-advance after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.nextStep()
                            }
                        }
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 80)
        }
    }
}

