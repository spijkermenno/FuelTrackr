//
//  OnboardingTrackingView.swift
//  FuelTrackr
//
//  Step 3: App Tracking Transparency permission request
//

import SwiftUI
import AppTrackingTransparency
import AdSupport

public struct OnboardingTrackingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isRequesting = false
    @State private var canRequestTracking = true
    
    public var body: some View {
        VStack {
            // Title and Description
            OnboardingHeader(
                title: NSLocalizedString("onboarding_tracking_title", comment: "Help Improve FuelTrackr"),
                description: NSLocalizedString("onboarding_tracking_description", comment: "Allow tracking to help us improve the app experience and provide personalized content."),
                spacing: 16
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Icon
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 80))
                .foregroundColor(OnboardingColors.primaryBlue)
                .padding(.bottom, 40)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                if canRequestTracking {
                    Button(action: {
                        requestTrackingPermission()
                    }) {
                        Text(NSLocalizedString("onboarding_tracking_allow", comment: "Allow Tracking"))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(OnboardingColors.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(OnboardingColors.primaryBlue)
                            .cornerRadius(16)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(isRequesting)
                }
                
                Button(action: {
                    // Skip - proceed to next step
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.nextStep()
                    }
                }) {
                    Text(NSLocalizedString("onboarding_tracking_skip", comment: "Ask App Not to Track"))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(OnboardingColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.clear)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isRequesting)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onAppear {
            checkTrackingAvailability()
        }
    }
    
    private func checkTrackingAvailability() {
        // Check if tracking authorization can be requested
        // ATT can only be requested once per app install, and only on iOS 14.5+
        let status = ATTrackingManager.trackingAuthorizationStatus
        canRequestTracking = (status == .notDetermined)
        
        // If already determined, proceed automatically after a short delay
        if !canRequestTracking {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.nextStep()
                }
            }
        }
    }
    
    private func requestTrackingPermission() {
        // Double-check status before requesting
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            // Already determined, proceed to next step
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.nextStep()
            }
            return
        }
        
        isRequesting = true
        
        // Request tracking authorization
        ATTrackingManager.requestTrackingAuthorization { status in
            print("Tracking authorization status: \(status.rawValue)")
            
            // Proceed to next step regardless of permission result
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isRequesting = false
                canRequestTracking = false
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.nextStep()
                }
            }
        }
    }
}
