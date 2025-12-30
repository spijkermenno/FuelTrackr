//
//  OnboardingVehicleBrandView.swift
//  FuelTrackr
//
//  Step 4: Vehicle brand selection
//

import SwiftUI

public struct OnboardingVehicleFuelTypeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isCustomBrand: Bool = false
    @State private var showSelectionSheet: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    public var body: some View {
        VStack {
            OnboardingHeader(
                title: NSLocalizedString("onboarding_vehicle_fuel_type_title", comment: "Vehicle fuel type"),
                description: NSLocalizedString("onboarding_vehicle_fuel_type_question", comment: "what fuel type does this vehicle use")
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Input Field
            VStack(spacing: 16) {
                TextButton(
                    title: NSLocalizedString("fuel_liquid", comment: "Petrol and Diesel"),
                    isSelected: viewModel.vehicleFuelType == .liquid,
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
                
                TextButton(
                    title: NSLocalizedString("fuel_electric", comment: "Electric"),
                    isSelected: viewModel.vehicleFuelType == .electric,
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
                
                TextButton(
                    title: NSLocalizedString("fuel_hydrogen", comment: "Hydrogen fuel"),
                    isSelected: viewModel.vehicleFuelType == .hydrogen,
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
        .contentShape(Rectangle())
    }
}
