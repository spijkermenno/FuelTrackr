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
    
    @Environment(\.modelContext) public var context

    @State public var showDeleteConfirmation = false
    @State public var showAddFuelSheet = false
    @State public var showAddMaintenanceSheet = false
    @State public var showEditVehicleSheet = false

    public init(
        vehicleViewModel: VehicleViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: vehicleViewModel)
        _settingsViewModel = StateObject(wrappedValue: settingsViewModel)
    }

    public var body: some View {
        ZStack {
            if let vehicle = viewModel.resolvedVehicle(context: context) {
                ActiveVehicleContent(
                    vehicleViewModel: viewModel,
                    showAddFuelSheet: $showAddFuelSheet,
                    showAddMaintenanceSheet: $showAddMaintenanceSheet,
                    showEditVehicleSheet: $showEditVehicleSheet
                )
                .onAppear {
                    // TODO: Analytics wrapper
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
            // Schedule monthly recap notification
        }
    }
}
