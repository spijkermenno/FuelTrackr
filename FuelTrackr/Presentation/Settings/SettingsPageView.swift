// MARK: - Package: Presentation

//
//  SettingsPageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 25/04/2025.
//

import SwiftUI
import SwiftData
import Domain
import UserNotifications
import ScovilleKit
import FirebaseAnalytics
import Data

public struct SettingsPageView: View {
    @StateObject public var viewModel: SettingsViewModel
    @StateObject public var vehicleViewModel: VehicleViewModel
    @StateObject private var purchaseManager = InAppPurchaseManager.shared
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation = false
    @State private var showPayWall = false
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @StateObject private var reviewPrompter = ReviewPrompter.shared
    @State private var showAppSuggestion = false
    @State private var exportShareItem: ExportShareItem?

    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        NavigationView {
            List {
                // Subscription/Purchase Status
                Section(header: Text(NSLocalizedString("pro_status", comment: ""))
                    .foregroundColor(colors.onSurface)) {
                    if purchaseManager.hasActiveSubscription {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(purchaseManager.currentPurchaseInfo.displayName)
                                    .font(Theme.typography.bodyFont)
                                    .foregroundColor(colors.onBackground)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(colors.success)
                            }
                            
                            if let purchaseDate = purchaseManager.currentPurchaseInfo.purchaseDate {
                                Text(String(format: NSLocalizedString("pro_purchased", comment: ""), formatDate(purchaseDate)))
                                    .font(Theme.typography.footnoteFont)
                                    .foregroundColor(colors.onSurface)
                            }
                            
                            if let expirationDate = purchaseManager.currentPurchaseInfo.expirationDate,
                               purchaseManager.currentPurchaseInfo.type != .lifetime {
                                Text(String(format: NSLocalizedString("pro_renews", comment: ""), formatDate(expirationDate)))
                                    .font(Theme.typography.footnoteFont)
                                    .foregroundColor(colors.onSurface)
                            }
                            
                            if purchaseManager.currentPurchaseInfo.type == .lifetime {
                                Text(NSLocalizedString("pro_never_expires", comment: ""))
                                    .font(Theme.typography.footnoteFont)
                                    .foregroundColor(colors.onSurface)
                            }
                        }
                        .padding(.vertical, Theme.dimensions.spacingXS)
                        
                        // Cancel subscription button (only for subscriptions)
                        if purchaseManager.currentPurchaseInfo.type != .lifetime {
                            Button(action: {
                                purchaseManager.openSubscriptionManagement()
                            }) {
                                    HStack {
                                        Text(NSLocalizedString("pro_manage_subscription", comment: ""))
                                            .foregroundColor(colors.primary)
                                            .font(Theme.typography.bodyFont)
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundColor(colors.primary)
                                    }
                            }
                            .padding(.vertical, Theme.dimensions.spacingXS)
                        }
                        
                        #if DEBUG
                        Button(action: {
                            purchaseManager.removeProStatus()
                        }) {
                            Text(NSLocalizedString("pro_remove_debug", comment: ""))
                                .foregroundColor(colors.error)
                                .font(Theme.typography.bodyFont)
                        }
                        .padding(.vertical, Theme.dimensions.spacingXS)
                        #endif
                    } else {
                        Button(action: {
                            showPayWall = true
                        }) {
                            HStack {
                                Text(NSLocalizedString("pro_upgrade", comment: ""))
                                    .foregroundColor(colors.primary)
                                    .font(Theme.typography.bodyFont)
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(colors.primary)
                            }
                        }
                        .padding(.vertical, Theme.dimensions.spacingXS)
                        
                        #if DEBUG
                        Button(action: {
                            purchaseManager.grantProStatus()
                        }) {
                            Text(NSLocalizedString("pro_grant_debug", comment: ""))
                                .foregroundColor(colors.primary)
                                .font(Theme.typography.bodyFont)
                        }
                        .padding(.vertical, Theme.dimensions.spacingXS)
                        #endif
                    }
                }
                
                // Notifications Section
                Section(header: Text(NSLocalizedString("notifications_section", comment: ""))
                    .foregroundColor(colors.onSurface)) {
                    Toggle(isOn: Binding(
                        get: { notificationAuthorizationStatus == .authorized },
                        set: { newValue in
                            if newValue {
                                // Request permission if not determined
                                if notificationAuthorizationStatus == .notDetermined {
                                    requestNotificationPermission()
                                } else if notificationAuthorizationStatus == .denied {
                                    // Open settings if denied
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            } else {
                                // If trying to disable, open settings
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            viewModel.updateNotifications(newValue)
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("notifications_toggle", comment: ""))
                                .font(Theme.typography.bodyFont)
                                .foregroundColor(colors.onBackground)
                            Text(NSLocalizedString("notifications_toggle_description", comment: ""))
                                .font(Theme.typography.captionFont)
                                .foregroundColor(colors.onSurface)
                        }
                    }
                }
                
                // Help & Feedback Section
                Section(
                    header: Text(NSLocalizedString("help_feedback_section", comment: ""))
                        .foregroundColor(colors.onSurface),
                    footer: Text(NSLocalizedString("help_feedback_footer", comment: ""))
                        .font(Theme.typography.captionFont)
                        .foregroundColor(colors.onSurface)
                ) {
                    Button(action: {
                        Scoville.track(FuelTrackrEvents.reviewButtonClicked)
                        Analytics.logEvent(FuelTrackrEvents.reviewButtonClicked.rawValue, parameters: nil)
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            ReviewPrompter.shared.maybeRequestReview(reason: .debug)
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: reviewPrompter.isFeedbackOnCooldown ? [colors.onSurface, colors.onSurface.opacity(0.7)] : [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString("review_app", comment: ""))
                                    .font(Theme.typography.bodyFont)
                                    .foregroundColor(reviewPrompter.isFeedbackOnCooldown ? colors.onSurface : colors.onBackground)
                                if reviewPrompter.isFeedbackOnCooldown {
                                    Text(NSLocalizedString("review_recent_feedback", comment: ""))
                                        .font(Theme.typography.captionFont)
                                        .foregroundColor(colors.onSurface)
                                } else {
                                    Text(NSLocalizedString("review_share_opinion", comment: ""))
                                        .font(Theme.typography.captionFont)
                                        .foregroundColor(colors.onSurface)
                                }
                            }
                            
                            Spacer()
                            
                            if !reviewPrompter.isFeedbackOnCooldown {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(colors.onSurface)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(reviewPrompter.isFeedbackOnCooldown)
                    .accessibilityLabel(NSLocalizedString("review_app", comment: ""))
                    
                    Button(action: {
                        Scoville.track(FuelTrackrEvents.suggestionButtonClicked)
                        Analytics.logEvent(FuelTrackrEvents.suggestionButtonClicked.rawValue, parameters: nil)
                        showAppSuggestion = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString("app_suggestion", comment: ""))
                                    .font(Theme.typography.bodyFont)
                                    .foregroundColor(colors.onBackground)
                                Text(NSLocalizedString("app_suggestion_subtitle", comment: ""))
                                    .font(Theme.typography.captionFont)
                                    .foregroundColor(colors.onSurface)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(colors.onSurface)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityLabel(NSLocalizedString("app_suggestion", comment: ""))
                }
                
                // Reset Vehicle
                Section(header: Text(NSLocalizedString("reset_section", comment: ""))
                    .foregroundColor(colors.onSurface)) {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text(NSLocalizedString("delete_vehicle_button", comment: ""))
                            .foregroundColor(colors.error)
                    }
                }
                
                #if DEBUG
                // Debug Section - Notification Testing & Export
                Section(header: Text("Debug")
                    .foregroundColor(colors.onSurface)) {
                    Button(action: {
                        let notificationManager = NotificationManager(settingsRepository: SettingsRepository())
                        notificationManager.scheduleTestNotification()
                        print("🔔 Debug: Test notification scheduled to arrive in 1 minute")
                    }) {
                        HStack {
                            Text("Test Notification (1 min)")
                                .foregroundColor(colors.primary)
                                .font(Theme.typography.bodyFont)
                            Spacer()
                            Image(systemName: "bell.badge")
                                .foregroundColor(colors.primary)
                        }
                    }
                    .padding(.vertical, Theme.dimensions.spacingXS)

                    Button(action: exportToJSON) {
                        HStack {
                            Text("Export to JSON")
                                .foregroundColor(colors.primary)
                                .font(Theme.typography.bodyFont)
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(colors.primary)
                        }
                    }
                    .padding(.vertical, Theme.dimensions.spacingXS)
                }
                #endif
            }
            .confirmationDialog(
                NSLocalizedString("delete_vehicle_confirmation_title", comment: ""),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete_confirmation_delete", comment: ""), role: .destructive) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        do {
                            try vehicleViewModel.deleteVehicle(context: context)
                            
                            // Track vehicle deletion
                            Task { @MainActor in
                                Scoville.track(FuelTrackrEvents.vehicleDeleted)
                                Analytics.logEvent(FuelTrackrEvents.vehicleDeleted.rawValue, parameters: nil)
                            }
                            
                            vehicleViewModel.loadActiveVehicle(context: context)
                        } catch {
                            print("Delete failed: \(error)")
                        }
                    }
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPayWall) {
                InAppPurchasePayWall()
            }
            .sheet(isPresented: $showAppSuggestion) {
                AppSuggestionView(isPresented: $showAppSuggestion)
            }
            #if DEBUG
            .sheet(item: $exportShareItem, onDismiss: { exportShareItem = nil }) { item in
                ShareSheet(items: [item.fileURL])
            }
            #endif
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text(NSLocalizedString("ok", comment: "")))
                )
            }
        }
        .background(colors.background)
        .task {
            await purchaseManager.checkPurchaseStatus()
            checkNotificationStatus()
        }
        .onAppear {
            checkNotificationStatus()
            // Reset review sheet state when view appears to prevent auto-opening
            if reviewPrompter.showCustomReview {
                reviewPrompter.showCustomReview = false
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status = settings.authorizationStatus
            Task { @MainActor in
                self.notificationAuthorizationStatus = status
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            Task { @MainActor in
                checkNotificationStatus()
            }
        }
    }

    #if DEBUG
    private func exportToJSON() {
        do {
            let vehicles = try context.fetch(FetchDescriptor<Vehicle>())
            let json = try VehicleJSONExporter().exportAll(vehicles)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HHmmss"
            let fileName = "FuelTrackr_Export_\(formatter.string(from: Date())).json"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try json.write(to: tempURL, atomically: true, encoding: .utf8)
            exportShareItem = ExportShareItem(fileURL: tempURL)
        } catch {
            alertTitle = "Export Failed"
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    #endif
}

#if DEBUG
private struct ExportShareItem: Identifiable {
    let id = UUID()
    let fileURL: URL
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
