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
    @StateObject public var settingsViewModel = SettingsViewModel()
    @StateObject public var addFuelUsageViewModel = AddFuelUsageViewModel()
    
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
                VehicleImageView(photoData: vehicleViewModel.activeVehicle?.photo)
                    .padding(.horizontal)
                
//                VehiclePurchaseBanner(
//                    isPurchased: true, //vehicle.isPurchased ?? false,
//                    purchaseDate: vehicle.purchaseDate,
//                    onConfirmPurchase: { showEditVehicleSheet = true }
//                )
//                .padding(.horizontal)
//                
                NewVehicleInfoCard(
                    licensePlate: vehicle.licensePlate,
                    mileage: vehicle.mileages.sorted(by: { $0.date < $1.date }).last?.value ?? 0,
                    purchaseDate: vehicle.purchaseDate,
                    productionDate: vehicle.manufacturingDate
                )
                .padding(.horizontal)

                let mock = [
                    VehicleStatisticsUiModel(period: Period.CurrentMonth, distanceDriven: 1230, fuelUsed: 84.3, totalCost: 123.2),
                    VehicleStatisticsUiModel(period: Period.LastMonth, distanceDriven: 2130, fuelUsed: 834.3, totalCost: 1233.2),
                    VehicleStatisticsUiModel(period: Period.YTD, distanceDriven: 12350, fuelUsed: 184.3, totalCost: 523.2),
                    VehicleStatisticsUiModel(period: Period.AllTime, distanceDriven: 1230, fuelUsed: 84.3, totalCost: 123.2),
                ]
                
                VehicleStatisticsCarouselView(items: mock)
                
//                GenericCarousel(height: 248) {
//                    CompactTripOverviewCard()
//                    CompactTripOverviewCard()
//                }
        
                // New Fuel usage history card
                
                // New Maintenance history card
                
                
                
//                GenericCarousel(height: 290) {
//                    VehicleInfoCard(viewModel: vehicleViewModel)
//                    
//                    if let vehicle = vehicleViewModel.activeVehicle, vehicle.mileages.count > 1 {
//                        MileageGraphView(
//                            mileageHistory: vehicle.mileages,
//                            isMetric: settingsViewModel.isUsingMetric
//                        )
//                    }
//                }
                
                FuelUsageView(
                    viewModel: vehicleViewModel,
                    showAddFuelSheet: $showAddFuelSheet,
                    isVehicleActive: vehicle.isPurchased ?? false
                )
                .padding(.horizontal)
//                
//                MaintenanceView(
//                    showAddMaintenanceSheet: $showAddMaintenanceSheet,
//                    isVehicleActive: vehicle.isPurchased ?? false
//                )
//                .padding(.horizontal)
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
