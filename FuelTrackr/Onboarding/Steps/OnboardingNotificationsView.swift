//
//  OnboardingNotificationsView.swift
//  FuelTrackr
//
//  Step 2: Notification permission request
//

import SwiftUI
import UserNotifications

public struct OnboardingNotificationsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isRequesting = false
    
    public var body: some View {
        VStack {
            // Title and Description
            OnboardingHeader(
                title: NSLocalizedString("onboarding_notifications_title", comment: "Stay Updated"),
                description: NSLocalizedString("onboarding_notifications_description", comment: "Enable notifications to receive reminders about fuel tracking and monthly recaps."),
                spacing: 16
            )
            .padding(.top, 116)
            
            Spacer()
            
            // Icon
            Image(systemName: "bell.badge")
                .font(.system(size: 80))
                .foregroundColor(OnboardingColors.primaryBlue)
                .padding(.bottom, 40)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text(NSLocalizedString("onboarding_notifications_allow", comment: "Enable Notifications"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(OnboardingColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(OnboardingColors.primaryBlue)
                        .cornerRadius(16)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isRequesting)
                
                Button(action: {
                    // Skip - proceed to next step
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.nextStep()
                    }
                }) {
                    Text(NSLocalizedString("onboarding_notifications_skip", comment: "Not Now"))
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
    }
    
    private func requestNotificationPermission() {
        isRequesting = true
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        center.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
            
            // Register for remote notifications if granted
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            // Proceed to next step regardless of permission result
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isRequesting = false
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.nextStep()
                }
            }
        }
    }
}
