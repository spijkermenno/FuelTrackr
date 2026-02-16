//
//  OnboardingFlowView.swift
//  FuelTrackr
//
//  Main coordinator view for the onboarding flow
//

import SwiftUI
import Domain
import SwiftData
import ScovilleKit

public struct OnboardingFlowView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @Environment(\.modelContext) private var context
    
    public let onComplete: () -> Void
    
    public init(
        viewModel: OnboardingViewModel = OnboardingViewModel(),
        onComplete: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            // Background - matches design colors
            OnboardingColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button - only show when there's a previous step
                if viewModel.currentStep.previous() != nil {
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.previousStep()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(OnboardingColors.primaryBlue)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                }
                
                // Step content - expands to fill available space
                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        OnboardingWelcomeView(viewModel: viewModel)
                    case .notifications:
                        OnboardingNotificationsView(viewModel: viewModel)
                    case .tracking:
                        OnboardingTrackingView(viewModel: viewModel)
                    case .unitSelection:
                        OnboardingUnitSelectionView(viewModel: viewModel)
                    case .vehicleName:
                        OnboardingVehicleNameView(viewModel: viewModel)
                    case .vehicleFuelType:
                        OnboardingVehicleFuelTypeView(viewModel: viewModel)
                    case .optionalDetails:
                        OnboardingOptionalDetailsView(viewModel: viewModel)
                    case .currentMileage:
                        OnboardingCurrentMileageView(viewModel: viewModel)
                    case .addPhoto:
                        OnboardingAddPhotoView(viewModel: viewModel)
                    case .completion:
                        OnboardingCompletionView(viewModel: viewModel, onComplete: onComplete)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(viewModel.currentStep.rawValue)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
                // Persistent progress indicator - only show when not on welcome, notifications, tracking, or completion
                if viewModel.currentStep != .welcome && viewModel.currentStep != .notifications && viewModel.currentStep != .tracking && viewModel.currentStep != .completion {
                    OnboardingProgressIndicator(
                        currentStep: viewModel.currentStepIndex,
                        totalSteps: viewModel.totalSteps
                    )
                    .padding(.bottom, 24)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            // Track onboarding started
            Task { @MainActor in
                Scoville.track(FuelTrackrEvents.onboardingStarted)
            }
        }
        .onChange(of: viewModel.currentStep) { _, newStep in
            // Track each onboarding step viewed
            Task { @MainActor in
                Scoville.track(
                    FuelTrackrEvents.onboardingStepViewed,
                    parameters: [
                        "step": newStep.rawValue.description,
                        "step_name": newStep.title
                    ]
                )
            }
        }
    }
}
