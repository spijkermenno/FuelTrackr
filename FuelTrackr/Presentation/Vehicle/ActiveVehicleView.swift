//
//  ActiveVehicleView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import SwiftData
import FirebaseAnalytics

struct ActiveVehicleView: View {
    @StateObject private var viewModel: VehicleViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var notificationHandler: NotificationHandler

    @State private var showDeleteConfirmation = false
    @State private var showAddFuelSheet = false
    @State private var showAddMaintenanceSheet = false
    @State private var showEditVehicleSheet = false
    @State private var isRefreshing = false

    init(
        vehicleViewModel: VehicleViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: vehicleViewModel)
        _settingsViewModel = StateObject(wrappedValue: settingsViewModel)
    }

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
            viewModel.loadActiveVehicle()
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
