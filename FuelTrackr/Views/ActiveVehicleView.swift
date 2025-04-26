import SwiftUI
import FirebaseAnalytics

struct ActiveVehicleView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var context
    @EnvironmentObject var notificationHandler: NotificationHandler

    @State private var showDeleteConfirmation = false
    @State private var showAddFuelSheet = false
    @State private var showAddMaintenanceSheet = false
    @State private var showEditVehicleSheet = false
    @State private var isRefreshing = false

    private let repository = SettingsRepository()

    var body: some View {
        ZStack {
            if isRefreshing {
                RefreshingView()
            } else {
                if let vehicle = viewModel.activeVehicle {
                    ActiveVehicleContent(
                        vehicleViewModel: viewModel,
                        settingsViewModel: settingsViewModel,
                        vehicle: vehicle,
                        showAddFuelSheet: $showAddFuelSheet,
                        showAddMaintenanceSheet: $showAddMaintenanceSheet,
                        showEditVehicleSheet: $showEditVehicleSheet
                    )
                    .onAppear {
                        Analytics.logEvent("active_vehicle_found", parameters: [
                            "vehicle_name": vehicle.name,
                            "license_plate": vehicle.licensePlate
                        ])
                        scheduleNextRecapNotification()
                    }
                } else {
                    NoActiveVehicleView()
                        .onAppear {
                            Analytics.logEvent("no_active_vehicle", parameters: nil)
                        }
                }
            }
        }
    }

    private func onRefresh() {
        isRefreshing = true
        DispatchQueue.main.async {
            viewModel.refresh(context: context)
            DispatchQueue.main.async {
                isRefreshing = false
            }
        }
    }

    private func scheduleNextRecapNotification() {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month], from: now)
        if let day = calendar.dateComponents([.day], from: now).day, day > 1 {
            components.month = (components.month ?? 0) + 1
            if components.month! > 12 {
                components.month = 1
                components.year = (components.year ?? 0) + 1
            }
        }
        components.day = 1
        components.hour = 18
        components.minute = 0
        components.second = 0
        if let next1st = calendar.date(from: components) {
            NotificationManager.shared.scheduleMonthlyRecapNotification(for: next1st)
        }
    }
}
