// MARK: - Package: Presentation

//
//  SettingsPageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 25/04/2025.
//

import SwiftUI
import Domain
import UserNotifications


public struct SettingsPageView: View {
    @StateObject public var viewModel: SettingsViewModel
    @StateObject public var vehicleViewModel: VehicleViewModel
    @StateObject private var purchaseManager = InAppPurchaseManager.shared
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
        
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation = false
    @State private var showPayWall = false
    
    public var body: some View {
        NavigationView {
            Form {
                // Subscription/Purchase Status
                Section(header: Text("Pro Status")) {
                    if purchaseManager.hasActiveSubscription {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(purchaseManager.currentPurchaseInfo.displayName)
                                    .font(Theme.typography.bodyFont)
                                    .foregroundColor(Theme.colors.onBackground)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            
                            if let purchaseDate = purchaseManager.currentPurchaseInfo.purchaseDate {
                                Text("Purchased: \(formatDate(purchaseDate))")
                                    .font(Theme.typography.footnoteFont)
                                    .foregroundColor(Theme.colors.onSurface)
                            }
                            
                            if let expirationDate = purchaseManager.currentPurchaseInfo.expirationDate,
                               purchaseManager.currentPurchaseInfo.type != .lifetime {
                                Text("Renews: \(formatDate(expirationDate))")
                                    .font(Theme.typography.footnoteFont)
                                    .foregroundColor(Theme.colors.onSurface)
                            }
                            
                            if purchaseManager.currentPurchaseInfo.type == .lifetime {
                                Text("Never expires")
                                    .font(Theme.typography.footnoteFont)
                                    .foregroundColor(Theme.colors.onSurface)
                            }
                        }
                        .padding(.vertical, Theme.dimensions.spacingXS)
                        
                        // Cancel subscription button (only for subscriptions)
                        if purchaseManager.currentPurchaseInfo.type != .lifetime {
                            Button(action: {
                                purchaseManager.openSubscriptionManagement()
                            }) {
                                HStack {
                                    Text("Manage Subscription")
                                        .foregroundColor(Theme.colors.primary)
                                        .font(Theme.typography.bodyFont)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(Theme.colors.primary)
                                }
                            }
                            .padding(.vertical, Theme.dimensions.spacingXS)
                        }
                        
                        #if DEBUG
                        Button(action: {
                            purchaseManager.removeProStatus()
                        }) {
                            Text("Remove Pro (Debug)")
                                .foregroundColor(Theme.colors.error)
                                .font(Theme.typography.bodyFont)
                        }
                        .padding(.vertical, Theme.dimensions.spacingXS)
                        #endif
                    } else {
                        Button(action: {
                            showPayWall = true
                        }) {
                            HStack {
                                Text("Upgrade to Pro")
                                    .foregroundColor(Theme.colors.primary)
                                    .font(Theme.typography.bodyFont)
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(Theme.colors.primary)
                            }
                        }
                        .padding(.vertical, Theme.dimensions.spacingXS)
                    }
                }
                
                // Reset Vehicle
                Section(header: Text(NSLocalizedString("reset_section", comment: ""))) {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text(NSLocalizedString("delete_vehicle_button", comment: ""))
                            .foregroundColor(Theme.colors.error)
                    }
                }
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
                                vehicleViewModel.loadActiveVehicle(context: context)
                            } catch {
                                print("Delete failed: \(error)")
                            }
                        }
                    }
                    Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
                }
        }
        .background(Theme.colors.background)
        .navigationTitle(NSLocalizedString("settings_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPayWall) {
            InAppPurchasePayWall()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text(NSLocalizedString("ok", comment: "")))
            )
        }
        .task {
            // Refresh purchase status when view appears
            await purchaseManager.checkPurchaseStatus()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}
