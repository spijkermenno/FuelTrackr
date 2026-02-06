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
   
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme

    @Binding public var showAddFuelSheet: Bool
    @Binding public var isShowingPayWall: Bool
    @Binding public var showAddMaintenanceSheet: Bool
    @Binding public var showEditVehicleSheet: Bool
    
    @State private var showFuelDetailsSheet = false
    @State private var showMergedPartialFillSheet = false
    @State private var selectedMergedGroupID: PersistentIdentifier?

    // MARK: - Edit Fuel Usage selection
    private struct FuelUsageSelection: Identifiable {
        let id: PersistentIdentifier
    }
    @State private var selectedFuelUsage: FuelUsageSelection?

    public init(
        vehicleViewModel: VehicleViewModel,
        showAddFuelSheet: Binding<Bool>,
        showAddMaintenanceSheet: Binding<Bool>,
        showEditVehicleSheet: Binding<Bool>,
        isShowingPayWall: Binding<Bool>
    ) {
        _vehicleViewModel = StateObject(wrappedValue: vehicleViewModel)
        _showAddFuelSheet = showAddFuelSheet
        _showAddMaintenanceSheet = showAddMaintenanceSheet
        _showEditVehicleSheet = showEditVehicleSheet
        _isShowingPayWall = isShowingPayWall
    }
    
    public var body: some View {
        ScrollView {
            if let vehicle = vehicleViewModel.resolvedVehicle(context: context) {
                VStack(alignment: .leading, spacing: 20) {
                    // Vehicle Image Carousel
                    VehicleImageCarouselView(
                        photoData: vehicle.photo,
                        licensePlate: vehicle.licensePlate,
                        currentMileage: vehicle.mileages.sorted(by: { $0.date < $1.date }).last?.value ?? 0,
                        purchaseDate: vehicle.purchaseDate,
                        productionDate: vehicle.manufacturingDate,
                        isUsingMetric: settingsViewModel.isUsingMetric
                    )
                    
                    Button("show paywall", action: {
                        isShowingPayWall = true
                    })
                    
                    // Monthly Fuel Summary Carousel
                    MonthlyFuelSummaryCarouselView(
                        vehicleViewModel: vehicleViewModel,
                        isUsingMetric: settingsViewModel.isUsingMetric
                    )
                    
                    // Fuel Consumption Section
                    FuelConsumptionSectionView(
                        entries: vehicle.fuelConsumptionEntries(limit: 10),
                        onAdd: { showAddFuelSheet = true },
                        onShowMore: {
                            showFuelDetailsSheet = true
                        },
                        onEdit: { entry in
                            selectedFuelUsage = FuelUsageSelection(id: entry.fuelUsageID)
                        },
                        onPartialFillTapped: nil
                    )
                    .environmentObject(settingsViewModel)
                    .padding(.horizontal, Theme.dimensions.spacingL)
                    
                    // Maintenance History Section
                    MaintenanceHistorySectionView(
                        entries: vehicle.maintenanceEntries(limit: 10),
                        isVehicleActive: vehicle.isPurchased ?? false,
                        onAdd: { showAddMaintenanceSheet = true },
                        onShowMore: {
                            // TODO: Navigate to full maintenance history
                        }
                    )
                    .environmentObject(settingsViewModel)
                    .padding(.horizontal, Theme.dimensions.spacingL)
                }
                .padding(.vertical, Theme.dimensions.spacingM)
            } else {
                Text("No active vehicle found.")
                    .padding()
            }
        }
        .background(Theme.colors(for: colorScheme).background)
        .navigationTitle(vehicleViewModel.resolvedVehicle(context: context)?.displayName ?? "")
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
        .sheet(isPresented: $isShowingPayWall) {
            InAppPurchasePayWall()
        }
        // Add Fuel Usage
        .sheet(isPresented: $showAddFuelSheet, onDismiss: {
            vehicleViewModel.loadActiveVehicle(context: context)
        }) {
            AddFuelUsageSheet(
                vehicleViewModel: vehicleViewModel
            )
            .presentationDetents([.fraction(0.65)])
            .presentationDragIndicator(.visible)
        }
        // Edit Fuel Usage (selected from preview list)
        .sheet(item: $selectedFuelUsage, onDismiss: {
            vehicleViewModel.loadActiveVehicle(context: context)
        }) { selection in
            EditFuelUsageSheet(
                vehicleViewModel: vehicleViewModel,
                fuelUsageID: selection.id
            )
            .presentationDetents([.fraction(0.65)])
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
        // Fuel Details Sheet
        .sheet(isPresented: $showFuelDetailsSheet, onDismiss: {
            vehicleViewModel.loadActiveVehicle(context: context)
        }) {
            FuelDetailsSheet(
                viewModel: vehicleViewModel,
                showAddFuelSheet: $showAddFuelSheet
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        // Merged Partial Fill Management Sheet
        .sheet(isPresented: $showMergedPartialFillSheet, onDismiss: {
            vehicleViewModel.loadActiveVehicle(context: context)
        }) {
            if let fuelUsageID = selectedMergedGroupID {
                MergedPartialFillManagementSheet(
                    fuelUsageID: fuelUsageID,
                    viewModel: vehicleViewModel,
                    onDismiss: {
                        showMergedPartialFillSheet = false
                        selectedMergedGroupID = nil
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            vehicleViewModel.loadActiveVehicle(context: context)
        }
    }
}
