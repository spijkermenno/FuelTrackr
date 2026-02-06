//
//  OnboardingCompletionView.swift
//  FuelTrackr
//
//  Step 10: Completion screen
//

import SwiftUI
import SwiftData
import Domain

public struct OnboardingCompletionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.modelContext) private var context
    
    let onComplete: () -> Void
    
    @State private var isAnimating = false
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Success Content
            VStack(spacing: 24) {
                // Title and Description with animations
                OnboardingHeader(
                    title: NSLocalizedString("onboarding_completion_title", comment: "Vehicle setup complete! 🎉"),
                    description: NSLocalizedString("onboarding_completion_description", comment: "FuelTrackr is now ready to help you track fuel, costs, and maintenance automatically."),
                    spacing: 24
                )
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .scaleEffect(isAnimating ? 1 : 0.9)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: isAnimating)
            }
            
            Spacer()
            
            // Go to Dashboard Button
            Button(action: {
                saveVehicleAndComplete()
            }) {
                Text(NSLocalizedString("onboarding_go_to_dashboard", comment: "Go to dashboard"))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(OnboardingColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(OnboardingColors.primaryBlue)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.bottom, 40)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                isAnimating = true
            }
        }
    }
    
    private func saveVehicleAndComplete() {
        let vehicle = viewModel.createVehicle()
        let initialMileage = viewModel.getValidatedMileage() ?? 0
        
        let vehicleViewModel = VehicleViewModel()
        vehicleViewModel.saveVehicle(vehicle: vehicle, initialMileage: initialMileage, context: context)
        
        withAnimation {
            onComplete()
        }
    }
}
