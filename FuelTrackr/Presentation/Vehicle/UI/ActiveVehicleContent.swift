// MARK: - Package: Presentation

//
//  ActiveVehicleContent.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI
import Domain

import SwiftData


public struct ActiveVehicleContent: View {
    @StateObject public var vehicleViewModel: VehicleViewModel
    public var settingsViewModel = SettingsViewModel()
    public var addFuelUsageViewModel = AddFuelUsageViewModel()
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var notificationHandler: NotificationHandler
    
    public let vehicle: Vehicle
    
    @Binding public var showAddFuelSheet: Bool
    @Binding public var showAddMaintenanceSheet: Bool
    @Binding public var showEditVehicleSheet: Bool
    
    public init(
        vehicleViewModel: VehicleViewModel,
        vehicle: Vehicle,
        showAddFuelSheet: Binding<Bool>,
        showAddMaintenanceSheet: Binding<Bool>,
        showEditVehicleSheet: Binding<Bool>
    ) {
        _vehicleViewModel = StateObject(wrappedValue: vehicleViewModel)
        self.vehicle = vehicle
        _showAddFuelSheet = showAddFuelSheet
        _showAddMaintenanceSheet = showAddMaintenanceSheet
        _showEditVehicleSheet = showEditVehicleSheet
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                GenericCarousel {
                    VehicleImageView(photoData: vehicleViewModel.activeVehicle?.photo)
                    CompactTripOverviewCard()
                }
                
                VehiclePurchaseBanner(
                    isPurchased: vehicle.isPurchased ?? false,
                    purchaseDate: vehicle.purchaseDate,
                    onConfirmPurchase: { showEditVehicleSheet = true }
                )
                .padding(.horizontal)
                
                GenericCarousel(height: 290) {
                    VehicleInfoCard(viewModel: vehicleViewModel)
                    
                    if let vehicle = vehicleViewModel.activeVehicle, vehicle.mileages.count > 1 {
                        MileageGraphView(
                            mileageHistory: vehicle.mileages,
                            isMetric: settingsViewModel.isUsingMetric
                        )
                    }
                }
                
                FuelUsageView(
                    viewModel: vehicleViewModel,
                    showAddFuelSheet: $showAddFuelSheet,
                    isVehicleActive: vehicle.isPurchased ?? false
                )
                .padding(.horizontal)
                
                MaintenanceView(
                    showAddMaintenanceSheet: $showAddMaintenanceSheet,
                    isVehicleActive: vehicle.isPurchased ?? false
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
        .sheet(isPresented: $showAddFuelSheet, onDismiss: { vehicleViewModel.loadActiveVehicle(context: context) }) {
            AddFuelUsageSheet(vehicleViewModel: vehicleViewModel, viewModel: addFuelUsageViewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddMaintenanceSheet, onDismiss: { vehicleViewModel.loadActiveVehicle(context: context) }) {
            AddMaintenanceSheet(viewModel: vehicleViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditVehicleSheet, onDismiss: { vehicleViewModel.loadActiveVehicle(context: context) }) {
            EditVehicleSheet(viewModel: vehicleViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            vehicleViewModel.loadActiveVehicle(context: context)
        }
    }
}
