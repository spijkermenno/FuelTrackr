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

    @Binding public var showAddFuelSheet: Bool
    @Binding public var showAddMaintenanceSheet: Bool
    @Binding public var showEditVehicleSheet: Bool

    // MARK: - Edit Fuel Usage selection
    private struct FuelUsageSelection: Identifiable {
        let id: PersistentIdentifier
    }
    @State private var selectedFuelUsage: FuelUsageSelection?

    public init(
        vehicleViewModel: VehicleViewModel,
        showAddFuelSheet: Binding<Bool>,
        showAddMaintenanceSheet: Binding<Bool>,
        showEditVehicleSheet: Binding<Bool>
    ) {
        _vehicleViewModel = StateObject(wrappedValue: vehicleViewModel)
        _showAddFuelSheet = showAddFuelSheet
        _showAddMaintenanceSheet = showAddMaintenanceSheet
        _showEditVehicleSheet = showEditVehicleSheet
    }
    
    public var body: some View {
        ScrollView {
            if let vehicle = vehicleViewModel.resolvedVehicle(context: context) {
                VStack(alignment: .leading, spacing: 16) {
                    VehicleImageView(photoData: vehicle.photo)
                        .padding(.horizontal)
                    
                    VehiclePurchaseBanner(
                        isPurchased: vehicle.isPurchased ?? false,
                        purchaseDate: vehicle.purchaseDate,
                        onConfirmPurchase: {
                            vehicleViewModel.confirmPurchase(context: context)
                        }
                    )
                    .padding(.horizontal)
                    
                    NewVehicleInfoCard(
                        licensePlate: vehicle.licensePlate,
                        mileage: vehicle.mileages.sorted(by: { $0.date < $1.date }).last?.value ?? 0,
                        purchaseDate: vehicle.purchaseDate,
                        productionDate: vehicle.manufacturingDate
                    )
                    .padding(.horizontal)
                    
                    VehicleStatisticsCarouselView(items: vehicleViewModel.vehicleStatistics(context: context))
                    
                    FuelUsagePreviewCard(
                        items: vehicle.latestFuelUsagePreviews(),
                        onAdd: { showAddFuelSheet = true },
                        onShowMore: {},
                        onEdit: { preview in
                            // Open edit sheet for this specific FuelUsage
                            selectedFuelUsage = FuelUsageSelection(id: preview.fuelUsageID)
                        }
                    )
                    .environmentObject(settingsViewModel)
                    .padding(.horizontal)
                    
                    MaintenancePreviewCard(
                        items: vehicle.latestMaintenancePreviews(),
                        isVehicleActive: vehicle.isPurchased ?? false,
                        onAdd: { showAddMaintenanceSheet = true },
                        onShowMore: {
                            // TODO: implement maintenance list
                            print("TODO(Not yet implemented)")
                        }
                    )
                    .padding(.horizontal)
                }
                .navigationTitle(vehicle.name)
            } else {
                Text("No active vehicle found.")
                    .padding()
            }
        }
        .id(vehicleViewModel.refreshID)
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showEditVehicleSheet = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination:
                        SettingsPageView(
                            viewModel: settingsViewModel,
                            vehicleViewModel: vehicleViewModel
                        )
                ) {
                    Image(systemName: "gear")
                        .foregroundColor(.primary)
                }
            }
        }
        // Add Fuel Usage
        .sheet(isPresented: $showAddFuelSheet, onDismiss: {
            vehicleViewModel.loadActiveVehicle(context: context)
        }) {
            AddFuelUsageSheet(
                vehicleViewModel: vehicleViewModel,
                viewModel: addFuelUsageViewModel
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        // Edit Fuel Usage (selected from preview list)
        .sheet(item: $selectedFuelUsage, onDismiss: {
            vehicleViewModel.loadActiveVehicle(context: context)
        }) { selection in
            EditFuelUsageSheet(
                vehicleViewModel: vehicleViewModel,
                viewModel: EditFuelUsageViewModel(),
                fuelUsageID: selection.id
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        // Add Maintenance
        .sheet(isPresented: $showAddMaintenanceSheet, onDismiss: {
            vehicleViewModel.loadActiveVehicle(context: context)
        }) {
            AddMaintenanceSheet(viewModel: vehicleViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        // Edit Vehicle
        .sheet(isPresented: $showEditVehicleSheet, onDismiss: {
            vehicleViewModel.loadActiveVehicle(context: context)
        }) {
            EditVehicleSheet(viewModel: vehicleViewModel)
                .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            vehicleViewModel.loadActiveVehicle(context: context)
        }
    }
}
