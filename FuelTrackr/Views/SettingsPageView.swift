import SwiftUI
import UserNotifications

struct SettingsPageView: View {
    private let repository = SettingsRepository()

    @ObservedObject private var viewModel: VehicleViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var isNotificationsEnabled: Bool
    @State private var isUsingMetric: Bool
    @State private var defaultTireInterval: Int
    @State private var defaultOilChangeInterval: Int
    @State private var defaultBrakeCheckInterval: Int
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
                if showNotification, let message = resetMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(8)
                        .padding([.leading, .trailing, .top])
                        .transition(.slide)
                        .zIndex(1)
                }

                Form {
                    Section(header: Text(NSLocalizedString("notifications_section", comment: ""))) {
                        Toggle(NSLocalizedString("enable_notifications", comment: ""), isOn: $isNotificationsEnabled)
                            .onChange(of: isNotificationsEnabled) { newValue in
                                if newValue {
                                    requestNotificationPermission()
                                } else {
                                    repository.setNotificationsEnabled(false)
                                    NotificationManager.shared.cancelAllNotifications()
                                }
                            }
                            .onAppear {
                                checkNotificationStatus()
                            }
                        
                        // Notifications disclaimer message.
                        Text(NSLocalizedString("notifications_disclaimer", comment: "Disclaimer for notifications"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                        
                        // Test notification button.
                        Button(action: {
                            let date = Date().addingTimeInterval(60)
                            NotificationManager.shared.scheduleMonthlyRecapNotification(for: date)
                            // Set a toast message to let the user know the test notification has been scheduled.
                            resetMessage = NSLocalizedString("test_notification_success", comment: "Notification scheduled message")
                            showNotification = true
                            hideNotificationAfterDelay()
                            
                            let formatter = DateFormatter()
                            formatter.timeZone = TimeZone.current
                            formatter.dateStyle = .full
                            formatter.timeStyle = .short
                            print("test notification scheduled for \(formatter.string(from: date))")
                        }) {
                            Text(NSLocalizedString("test_notification", comment: "Trigger test notification"))
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section(header: Text(NSLocalizedString("units_section", comment: ""))) {
                        Toggle(NSLocalizedString("use_metric_units", comment: "Toggle for using metric units"), isOn: $isUsingMetric)
                            .onChange(of: isUsingMetric) { newValue in
                                SettingsRepository().setUsingMetric(newValue)
                            }
                        
                        Toggle(NSLocalizedString("use_imperial_units", comment: "Toggle for using imperial units"), isOn: Binding(
                            get: { !isUsingMetric },
                            set: { newValue in
                                isUsingMetric = !newValue
                                SettingsRepository().setUsingMetric(isUsingMetric)
                            }
                        ))
                    }
                    .onChange(of: isUsingMetric) { newValue in
                        let conversionFactor = 1.60934
                        if newValue {
                            defaultTireInterval = 100 + Int((Double(defaultTireInterval) * conversionFactor).rounded(.toNearestOrEven) / 100) * 100
                            defaultOilChangeInterval = 100 + Int((Double(defaultOilChangeInterval) * conversionFactor).rounded(.toNearestOrEven) / 100) * 100
                            defaultBrakeCheckInterval = 100 + Int((Double(defaultBrakeCheckInterval) * conversionFactor).rounded(.toNearestOrEven) / 100) * 100
                        } else {
                            defaultTireInterval = Int((Double(defaultTireInterval) / conversionFactor).rounded(.toNearestOrEven) / 100) * 100
                            defaultOilChangeInterval = Int((Double(defaultOilChangeInterval) / conversionFactor).rounded(.toNearestOrEven) / 100) * 100
                            defaultBrakeCheckInterval = Int((Double(defaultBrakeCheckInterval) / conversionFactor).rounded(.toNearestOrEven) / 100) * 100
                        }
                        repository.setUsingMetric(newValue)
                        repository.setDefaultTireInterval(defaultTireInterval)
                        repository.setDefaultOilChangeInterval(defaultOilChangeInterval)
                        repository.setDefaultBrakeCheckInterval(defaultBrakeCheckInterval)
                    }

                    Section(header: Text(NSLocalizedString("default_maintenance_intervals", comment: ""))) {
                        Text(NSLocalizedString("maintenance_interval_description", comment: "Maintenance interval description"))
                            .font(.footnote)
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                        
                        Text(NSLocalizedString("notifications_disclaimer", comment: "Disclaimer for notifications"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                        
                        MaintenanceIntervalRow(
                            title: NSLocalizedString("tires", comment: ""),
                            value: $defaultTireInterval,
                            unit: isUsingMetric ? "km" : "mi"
                        ) {
                            repository.setDefaultTireInterval($0)
                        }

                        MaintenanceIntervalRow(
                            title: NSLocalizedString("oil_change", comment: ""),
                            value: $defaultOilChangeInterval,
                            unit: isUsingMetric ? "km" : "mi"
                        ) {
                            repository.setDefaultOilChangeInterval($0)
                        }

                        MaintenanceIntervalRow(
                            title: NSLocalizedString("brakes", comment: ""),
                            value: $defaultBrakeCheckInterval,
                            unit: isUsingMetric ? "km" : "mi"
                        ) {
                            repository.setDefaultBrakeCheckInterval($0)
                        }
                    }

                    Section(header: Text(NSLocalizedString("reset_section", comment: ""))) {
                        Button(action: {
                            resetType = .maintenance
                            showResetConfirmation = true
                        }) {
                            Text(NSLocalizedString("reset_maintenance_button", comment: ""))
                                .foregroundColor(.red)
                        }

                        Button(action: {
                            resetType = .fuelUsage
                            showResetConfirmation = true
                        }) {
                            Text(NSLocalizedString("reset_fuel_button", comment: ""))
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text(NSLocalizedString("delete_vehicle_button", comment: ""))
                                .foregroundColor(.red)
                        }
                    }
                }
                .confirmationDialog(
                    NSLocalizedString("delete_vehicle_confirmation_title", comment: ""),
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(NSLocalizedString("delete_confirmation_delete", comment: ""), role: .destructive) {
                        viewModel.deleteActiveVehicle(context: context)
                        dismiss()
                    }
                    Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
                }
                .confirmationDialog(
                    NSLocalizedString("reset_confirmation_title", comment: ""),
                    isPresented: $showResetConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(NSLocalizedString("reset_confirmation_confirm", comment: ""), role: .destructive) {
                        handleReset()
                    }
                    Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle(NSLocalizedString("settings_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text(NSLocalizedString("ok", comment: ""))))
        }
    }

    private func handleReset() {
        switch resetType {
        case .maintenance:
            if viewModel.resetAllMaintenance(context: context) {
                showSuccessMessage(NSLocalizedString("reset_maintenance_success", comment: ""))
            } else {
                showErrorMessage(NSLocalizedString("reset_maintenance_error", comment: ""))
            }
        case .fuelUsage:
            if viewModel.resetAllFuelUsage(context: context) {
                showSuccessMessage(NSLocalizedString("reset_fuel_success", comment: ""))
            } else {
                showErrorMessage(NSLocalizedString("reset_fuel_error", comment: ""))
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
                    showErrorMessage(NSLocalizedString("notification_permission_error", comment: ""))
                } else {
                    isNotificationsEnabled = granted
                    repository.setNotificationsEnabled(granted)
                    if !granted {
                        alertTitle = NSLocalizedString("notifications_disabled_title", comment: "")
                        alertMessage = NSLocalizedString("notifications_disabled_message", comment: "")
                        showAlert = true
                    }
                }
            }
        }
    }
}
