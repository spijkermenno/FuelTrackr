//
//  ActiveVehicleContent.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI
import SwiftData

struct ActiveVehicleContent: View {
    @StateObject private var vehicleViewModel: VehicleViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var notificationHandler: NotificationHandler

    var vehicle: Vehicle

    @Binding var showAddFuelSheet: Bool
    @Binding var showAddMaintenanceSheet: Bool
    @Binding var showEditVehicleSheet: Bool

    init(
        vehicleViewModel: VehicleViewModel,
        settingsViewModel: SettingsViewModel,
        vehicle: Vehicle,
        showAddFuelSheet: Binding<Bool>,
        showAddMaintenanceSheet: Binding<Bool>,
        showEditVehicleSheet: Binding<Bool>
    ) {
        _vehicleViewModel = StateObject(wrappedValue: vehicleViewModel)
        _settingsViewModel = StateObject(wrappedValue: settingsViewModel)
        self.vehicle = vehicle
        _showAddFuelSheet = showAddFuelSheet
        _showAddMaintenanceSheet = showAddMaintenanceSheet
        _showEditVehicleSheet = showEditVehicleSheet
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                GenericCarousel {
                    VehicleImageView(photoData: vehicleViewModel.activeVehicle?.photo)
                    CompactTripOverviewCard(viewModel: vehicleViewModel)
                }
                
                VehiclePurchaseBanner(
                    isPurchased: vehicle.isPurchased,
                    purchaseDate: vehicle.purchaseDate,
                    onConfirmPurchase: { showEditVehicleSheet = true }
                )
                .padding(.horizontal)
                
                GenericCarousel(height: 290) {
                    VehicleInfoCard(viewModel: vehicleViewModel)
                    
                    if let vehicle = vehicleViewModel.activeVehicle, vehicle.mileages.count > 1 {
                        MileageGraphView(
                            mileageHistory: vehicle.mileages,
                            isMetric: SettingsRepositoryImpl().isUsingMetric()
                        )
                    }
                }

                FuelUsageView(
                    viewModel: vehicleViewModel,
                    showAddFuelSheet: $showAddFuelSheet,
                    isVehicleActive: vehicle.isPurchased
                )
                .padding(.horizontal)

                MaintenanceView(
                    viewModel: vehicleViewModel,
                    showAddMaintenanceSheet: $showAddMaintenanceSheet,
                    isVehicleActive: vehicle.isPurchased
                )
                .padding(.horizontal)

            }
        }
        .id(vehicleViewModel.refreshID)
        .background(Color(UIColor.systemBackground))
        .navigationTitle(vehicle.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showEditVehicleSheet = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsPageView(viewModel: settingsViewModel)) {
                    Image(systemName: "gear")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showAddFuelSheet, onDismiss: { vehicleViewModel.loadActiveVehicle() }) {
            AddFuelUsageSheet(context: context, vehicleViewModel: vehicleViewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddMaintenanceSheet, onDismiss: { vehicleViewModel.loadActiveVehicle() }) {
            AddMaintenanceSheet(viewModel: vehicleViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditVehicleSheet, onDismiss: { vehicleViewModel.loadActiveVehicle() }) {
            EditVehicleSheet(viewModel: vehicleViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
