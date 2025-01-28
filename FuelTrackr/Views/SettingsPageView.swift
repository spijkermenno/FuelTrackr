//
//  SettingsPageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/01/2025.
//

import SwiftUI

struct SettingsPageView: View {
    private let repository = SettingsRepository()

    @ObservedObject private var viewModel: VehicleViewModel
    @Environment(\.modelContext) private var context

    @State private var isNotificationsEnabled: Bool
    @State private var isUsingMetric: Bool
    @State private var defaultTireInterval: Int
    @State private var defaultOilChangeInterval: Int
    @State private var defaultBrakeCheckInterval: Int
    @State private var showResetConfirmation = false
    @State private var resetType: ResetType = .none
    @State private var resetMessage: String? // Message to show in the notification
    @State private var showNotification = false // Control visibility of the notification

    private enum ResetType {
        case maintenance
        case fuelUsage
        case none
    }

    init(viewModel: VehicleViewModel) {
        self.viewModel = viewModel
        _isNotificationsEnabled = State(initialValue: repository.isNotificationsEnabled())
        _isUsingMetric = State(initialValue: repository.isUsingMetric())
        _defaultTireInterval = State(initialValue: repository.defaultTireInterval())
        _defaultOilChangeInterval = State(initialValue: repository.defaultOilChangeInterval())
        _defaultBrakeCheckInterval = State(initialValue: repository.defaultBrakeCheckInterval())
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Notification Banner
                if showNotification, let message = resetMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding([.leading, .trailing, .top])
                        .transition(.slide)
                        .zIndex(1)
                }

                Form {
                    // Notifications Section
                    // Notifications Section
                    Section(header: Text(NSLocalizedString("notifications_section", comment: "Notifications"))) {
                        Toggle(NSLocalizedString("enable_notifications", comment: "Enable Notifications"), isOn: $isNotificationsEnabled)
                            .onChange(of: isNotificationsEnabled) { newValue in
                                if newValue {
                                    requestNotificationPermission()
                                } else {
                                    repository.setNotificationsEnabled(false)
                                }
                            }
                            .onAppear {
                                checkNotificationStatus()
                            }
                    }

                    // Units Section
                    Section(header: Text(NSLocalizedString("units_section", comment: "Units"))) {
                        Picker(NSLocalizedString("measurement_system", comment: "Measurement System"), selection: $isUsingMetric) {
                            Text(NSLocalizedString("metric", comment: "Metric (km, L)")).tag(true)
                            Text(NSLocalizedString("imperial", comment: "Imperial (mi, gal)")).tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: isUsingMetric) { newValue in
                            repository.setUsingMetric(newValue)
                        }
                    }

                    // Default Maintenance Intervals Section
                    Section(header: Text(NSLocalizedString("default_maintenance_intervals", comment: "Default Maintenance Intervals"))) {
                        MaintenanceIntervalRow(
                            title: NSLocalizedString("tires", comment: "Tires"),
                            value: $defaultTireInterval,
                            unit: isUsingMetric ? "km" : "mi"
                        ) {
                            repository.setDefaultTireInterval($0)
                        }

                        MaintenanceIntervalRow(
                            title: NSLocalizedString("oil_change", comment: "Oil Change"),
                            value: $defaultOilChangeInterval,
                            unit: isUsingMetric ? "km" : "mi"
                        ) {
                            repository.setDefaultOilChangeInterval($0)
                        }

                        MaintenanceIntervalRow(
                            title: NSLocalizedString("brakes", comment: "Brakes"),
                            value: $defaultBrakeCheckInterval,
                            unit: isUsingMetric ? "km" : "mi"
                        ) {
                            repository.setDefaultBrakeCheckInterval($0)
                        }
                    }

                    // Reset Data Section
                    Section(header: Text(NSLocalizedString("reset_section", comment: "Reset Data"))) {
                        Button(action: {
                            resetType = .maintenance
                            showResetConfirmation = true
                        }) {
                            Text(NSLocalizedString("reset_maintenance_button", comment: "Reset all maintenance data"))
                                .foregroundColor(.red)
                        }

                        Button(action: {
                            resetType = .fuelUsage
                            showResetConfirmation = true
                        }) {
                            Text(NSLocalizedString("reset_fuel_button", comment: "Reset all fuel usage data"))
                                .foregroundColor(.red)
                        }
                    }
                }
                .confirmationDialog(
                    NSLocalizedString("reset_confirmation_title", comment: "Are you sure?"),
                    isPresented: $showResetConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(NSLocalizedString("reset_confirmation_confirm", comment: "Confirm reset"), role: .destructive) {
                        handleReset()
                    }
                    Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) {}
                }
            }
        }
        .navigationTitle(NSLocalizedString("settings_title", comment: "Settings"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleReset() {
        switch resetType {
        case .maintenance:
            if viewModel.resetAllMaintenance(context: context) {
                showSuccessMessage(NSLocalizedString("reset_maintenance_success", comment: "Maintenance data reset successfully"))
            } else {
                showErrorMessage(NSLocalizedString("reset_maintenance_error", comment: "Error resetting maintenance data"))
            }
        case .fuelUsage:
            if viewModel.resetAllFuelUsage(context: context) {
                showSuccessMessage(NSLocalizedString("reset_fuel_success", comment: "Fuel usage data reset successfully"))
            } else {
                showErrorMessage(NSLocalizedString("reset_fuel_error", comment: "Error resetting fuel usage data"))
            }
        case .none:
            break
        }
    }

    private func showSuccessMessage(_ message: String) {
        resetMessage = message
        showNotification = true
        hideNotificationAfterDelay()
    }

    private func showErrorMessage(_ message: String) {
        resetMessage = message
        showNotification = true
        hideNotificationAfterDelay()
    }

    private func hideNotificationAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showNotification = false
            }
        }
    }
    
    private func checkNotificationStatus() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    isNotificationsEnabled = false
                    repository.setNotificationsEnabled(false)
                }
            }
        }
    }

    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notifications: \(error.localizedDescription)")
                    showErrorMessage(NSLocalizedString("notification_permission_error", comment: "Error requesting notification permission"))
                } else {
                    isNotificationsEnabled = granted
                    repository.setNotificationsEnabled(granted)
                    if !granted {
                        showNotificationPermissionAlert()
                    }
                }
            }
        }
    }

    private func showNotificationPermissionAlert() {
        let alertTitle = NSLocalizedString("notifications_disabled_title", comment: "Notifications Disabled")
        let alertMessage = NSLocalizedString("notifications_disabled_message", comment: "Enable notifications in settings for reminders.")
        showAlert(title: alertTitle, message: alertMessage)
    }

    private func showAlert(title: String, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "OK"), style: .default))
        windowScene.windows.first?.rootViewController?.present(alert, animated: true)
    }
}

// MARK: - Maintenance Interval Row
struct MaintenanceIntervalRow: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let onValueChange: (Int) -> Void

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: $value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .onChange(of: value, perform: onValueChange)
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
}
