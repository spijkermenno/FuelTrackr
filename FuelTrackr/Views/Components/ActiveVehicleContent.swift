//
//  ActiveVehicleContent.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI

struct ActiveVehicleContent: View {
    var vehicleViewModel: VehicleViewModel
    var settingsViewModel: SettingsViewModel
    var vehicle: Vehicle

    @Binding var showAddFuelSheet: Bool
    @Binding var showAddMaintenanceSheet: Bool
    @Binding var showEditVehicleSheet: Bool

    @Environment(\.modelContext) private var context
    @EnvironmentObject var notificationHandler: NotificationHandler

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
                                isMetric: SettingsRepository().isUsingMetric()
                            )
                        }
                }
                
                
//                VehicleInfoView(viewModel: viewModel)
//                    .padding(.horizontal)

                FuelUsageView(viewModel: vehicleViewModel, showAddFuelSheet: $showAddFuelSheet, isVehicleActive: vehicle.isPurchased)
                    .padding(.horizontal)

                
                MaintenanceView(viewModel: vehicleViewModel, showAddMaintenanceSheet: $showAddMaintenanceSheet, isVehicleActive: vehicle.isPurchased)
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
        .sheet(isPresented: $showAddFuelSheet, onDismiss: { vehicleViewModel.refresh(context: context) }) {
            AddFuelUsageSheet(viewModel: vehicleViewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddMaintenanceSheet, onDismiss: { vehicleViewModel.refresh(context: context) }) {
            AddMaintenanceSheet(viewModel: vehicleViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditVehicleSheet, onDismiss: { vehicleViewModel.refresh(context: context) }) {
            EditVehicleSheet(viewModel: vehicleViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
