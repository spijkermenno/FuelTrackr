// MARK: - Package: Presentation

//
//  ActiveVehicleView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain
import SwiftData
import FirebaseAnalytics


public struct ActiveVehicleView: View {
    @StateObject public var viewModel: VehicleViewModel
    @StateObject public var settingsViewModel: SettingsViewModel
//     public var notificationManager: NotificationManagerProtocol

    @Environment(\.modelContext) public var context
    @EnvironmentObject public var notificationHandler: NotificationHandler

    @State public var showDeleteConfirmation = false
    @State public var showAddFuelSheet = false
    @State public var showAddMaintenanceSheet = false
    @State public var showEditVehicleSheet = false
    @State public var isRefreshing = false

    public init(
        vehicleViewModel: VehicleViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: vehicleViewModel)
        _settingsViewModel = StateObject(wrappedValue: settingsViewModel)
    }

    public var body: some View {
        ZStack {
            if isRefreshing {
                RefreshingView()
            } else {
                if let vehicle = viewModel.activeVehicle {
                    ActiveVehicleContent(
                        vehicleViewModel: viewModel,
                        vehicle: vehicle,
                        showAddFuelSheet: $showAddFuelSheet,
                        showAddMaintenanceSheet: $showAddMaintenanceSheet,
                        showEditVehicleSheet: $showEditVehicleSheet
                    )
                    .onAppear {
                        // TODO ANALYTICS WRAPPER
//                        Analytics.logEvent("active_vehicle_found", parameters: [
//                            "vehicle_name": vehicle.name,
//                            "license_plate": vehicle.licensePlate
//                        ])
                        scheduleNextRecapNotification()
                    }
                } else {
                    NoActiveVehicleView()
                        .onAppear {
                            // TODO ANALYTICS WRAPPER

                            //Analytics.logEvent("no_active_vehicle", parameters: nil)
                        }
                }
            }
        }
    }

    public func onRefresh() {
        isRefreshing = true
        DispatchQueue.main.async {
            viewModel.loadActiveVehicle(context: context)
            DispatchQueue.main.async {
                isRefreshing = false
            }
        }
    }

    public func scheduleNextRecapNotification() {
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
            //notificationManager.scheduleMonthlyRecapNotification(for: next1st)
        }
    }
}
