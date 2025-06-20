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
    //   private var notificationManager: NotificationManagerProtocol
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
        
    @State private var showResetConfirmation = false
    @State private var resetType: ResetType = .none
    @State private var resetMessage: String?
    @State private var showNotification = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation = false
    
    private enum ResetType {
        case maintenance
        case fuelUsage
        case none
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showNotification, let message = resetMessage {
                    Text(message)
                        .font(Theme.typography.footnoteFont)
                        .foregroundColor(.white)
                        .padding(Theme.dimensions.spacingM)
                        .frame(maxWidth: .infinity)
                        .background(Theme.colors.onSurface.opacity(0.7))
                        .cornerRadius(Theme.dimensions.radiusCard)
                        .padding([.leading, .trailing, .top], Theme.dimensions.spacingM)
                        .transition(.slide)
                        .zIndex(1)
                }
                
                Form {
                    // Notifications
                    Section(header: Text(NSLocalizedString("notifications_section", comment: ""))) {
                        Toggle(NSLocalizedString("enable_notifications", comment: ""), isOn: $viewModel.isNotificationsEnabled)
                            .onChange(of: viewModel.isNotificationsEnabled) { newValue in
                                viewModel.updateNotifications(newValue)
                                if newValue {
                                    requestNotificationPermission()
                                } else {
                                    //                                    notificationManager.cancelAllNotifications()
                                }
                            }
                        
                        Text(NSLocalizedString("notifications_disclaimer", comment: ""))
                            .font(Theme.typography.footnoteFont)
                            .foregroundColor(Theme.colors.onSurface)
                            .padding(.vertical, Theme.dimensions.spacingS)
                        
                        Button(action: {
                            let date = Date().addingTimeInterval(60)
                            //                            notificationManager.scheduleMonthlyRecapNotification(for: date)
                            resetMessage = NSLocalizedString("test_notification_success", comment: "")
                            showNotification = true
                            hideNotificationAfterDelay()
                        }) {
                            Text(NSLocalizedString("test_notification", comment: ""))
                                .foregroundColor(Theme.colors.primary)
                                .font(Theme.typography.bodyFont)
                        }
                        .padding(.vertical, Theme.dimensions.spacingXS)
                        .disabled(!viewModel.isNotificationsEnabled)
                    }
                    
                    // Currency
                    Section(header: Text(NSLocalizedString("currency_section", comment: ""))) {
                        Menu {
                            ForEach(Currency.allCases, id: \.self) { currency in
                                Button(action: {
                                    viewModel.updateCurrency(currency)
                                }) {
                                    Text(currency.displayName)
                                        .font(Theme.typography.bodyFont)
                                }
                            }
                        } label: {
                            HStack {
                                Text(NSLocalizedString("select_currency", comment: ""))
                                    .font(Theme.typography.bodyFont)
                                Spacer()
                                Text(viewModel.selectedCurrency.symbol)
                                    .foregroundColor(Theme.colors.onSurface)
                                    .font(Theme.typography.bodyFont)
                            }
                        }
                    }
                    
                    // Units
                    Section(header: Text(NSLocalizedString("units_section", comment: ""))) {
                        Toggle(NSLocalizedString("use_metric_units", comment: ""), isOn: $viewModel.isUsingMetric)
                            .onChange(of: viewModel.isUsingMetric) { newValue in
                                viewModel.updateMetricSystem(newValue)
                            }
                        
                        Toggle(NSLocalizedString("use_imperial_units", comment: ""), isOn: Binding(
                            get: { !viewModel.isUsingMetric },
                            set: { newValue in
                                viewModel.updateMetricSystem(!newValue)
                            }
                        ))
                    }
                    
                    // Maintenance Intervals
                    Section(header: Text(NSLocalizedString("default_maintenance_intervals", comment: ""))) {
                        Text(NSLocalizedString("maintenance_interval_description", comment: ""))
                            .font(Theme.typography.footnoteFont)
                            .foregroundColor(Theme.colors.onBackground)
                            .padding(.vertical, Theme.dimensions.spacingS)
                        
                        MaintenanceIntervalRow(
                            title: NSLocalizedString("tires", comment: ""),
                            value: $viewModel.defaultTireInterval,
                            unit: viewModel.isUsingMetric ? "km" : "mi"
                        ) { viewModel.updateTireInterval($0) }
                        
                        MaintenanceIntervalRow(
                            title: NSLocalizedString("oil_change", comment: ""),
                            value: $viewModel.defaultOilChangeInterval,
                            unit: viewModel.isUsingMetric ? "km" : "mi"
                        ) { viewModel.updateOilChangeInterval($0) }
                        
                        MaintenanceIntervalRow(
                            title: NSLocalizedString("brakes", comment: ""),
                            value: $viewModel.defaultBrakeCheckInterval,
                            unit: viewModel.isUsingMetric ? "km" : "mi"
                        ) { viewModel.updateBrakeCheckInterval($0) }
                    }
                    
                    // Reset
                    Section(header: Text(NSLocalizedString("reset_section", comment: ""))) {
                        Button(action: {
                            resetType = .maintenance
                            showResetConfirmation = true
                        }) {
                            Text(NSLocalizedString("reset_maintenance_button", comment: ""))
                                .foregroundColor(Theme.colors.error)
                        }
                        
                        Button(action: {
                            resetType = .fuelUsage
                            showResetConfirmation = true
                        }) {
                            Text(NSLocalizedString("reset_fuel_button", comment: ""))
                                .foregroundColor(Theme.colors.error)
                        }
                        
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
                .confirmationDialog(
                    NSLocalizedString("reset_confirmation_title", comment: ""),
                    isPresented: $showResetConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(NSLocalizedString("reset_confirmation_confirm", comment: ""), role: .destructive) {
                        // Implement reset logic
                    }
                    Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
                }
            }
        }
        .background(Theme.colors.background)
        .navigationTitle(NSLocalizedString("settings_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text(NSLocalizedString("ok", comment: "")))
            )
        }
    }
    
    private func hideNotificationAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showNotification = false
            }
        }
    }
    
    private func requestNotificationPermission() {
        //        notificationManager.requestAuthorization { granted in
        //            DispatchQueue.main.async {
        //                viewModel.updateNotifications(granted)
        //            }
        //        }
    }
}
