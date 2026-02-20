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
    @ObservedObject private var purchaseManager = InAppPurchaseManager.shared
   
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme

    @Binding public var showAddFuelSheet: Bool
    @Binding public var isShowingPayWall: Bool
    @Binding public var showAddMaintenanceSheet: Bool
    @Binding public var showEditVehicleSheet: Bool
    
    /// When true, forces the offer banner to show (for previews). Default nil uses real purchase manager state.
    var forceShowOfferBanner: Bool? = nil
    
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
        isShowingPayWall: Binding<Bool>,
        forceShowOfferBanner: Bool? = nil
    ) {
        _vehicleViewModel = StateObject(wrappedValue: vehicleViewModel)
        _showAddFuelSheet = showAddFuelSheet
        _showAddMaintenanceSheet = showAddMaintenanceSheet
        _showEditVehicleSheet = showEditVehicleSheet
        _isShowingPayWall = isShowingPayWall
        self.forceShowOfferBanner = forceShowOfferBanner
    }
    
    public var body: some View {
        ScrollView {
            if let vehicle = vehicleViewModel.resolvedVehicle(context: context) {
                VStack(alignment: .leading, spacing: 12) {
                    // Offer banner for non-premium users when an introductory offer is available
                    if forceShowOfferBanner ?? (!purchaseManager.hasActiveSubscription && purchaseManager.hasEligibleOffer) {
                        OfferBannerView(
                            onTap: { isShowingPayWall = true },
                            discountPercent: forceShowOfferBanner == true ? 40 : purchaseManager.eligibleOfferDiscountPercent
                        )
                        .padding(.horizontal, Theme.dimensions.spacingL)
                    }
                    
                    // Vehicle Image Carousel (only if photo exists) or Vehicle Details Card
                    if let photoData = vehicle.photo, !photoData.isEmpty {
                        VehicleImageCarouselView(
                            photoData: photoData,
                            vehicleName: vehicle.name,
                            licensePlate: nil,
                            fuelType: vehicle.fuelType,
                            currentMileage: vehicle.mileages.sorted(by: { $0.date < $1.date }).last?.value ?? 0,
                            purchaseDate: vehicle.purchaseDate,
                            productionDate: vehicle.manufacturingDate,
                            isUsingMetric: settingsViewModel.isUsingMetric
                        )
                    } else {
                        // Show only vehicle details card when no photo
                        VehicleDetailsCard(
                            vehicleName: vehicle.name,
                            licensePlate: nil,
                            fuelType: vehicle.fuelType,
                            currentMileage: vehicle.mileages.sorted(by: { $0.date < $1.date }).last?.value ?? 0,
                            purchaseDate: vehicle.purchaseDate,
                            productionDate: vehicle.manufacturingDate,
                            isUsingMetric: settingsViewModel.isUsingMetric
                        )
                        .frame(height: 190)
                        .padding(.horizontal, Theme.dimensions.spacingL)
                    }
                    
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
                            // Check premium status before showing fuel details
                            if InAppPurchaseManager.shared.hasActiveSubscription {
                                showFuelDetailsSheet = true
                            } else {
                                isShowingPayWall = true
                            }
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
                        onAdd: {
                            // Check premium status before adding maintenance
                            if InAppPurchaseManager.shared.hasActiveSubscription {
                                showAddMaintenanceSheet = true
                            } else {
                                isShowingPayWall = true
                            }
                        },
                        onShowMore: {
                            // Check premium status before showing maintenance details
                            if InAppPurchaseManager.shared.hasActiveSubscription {
                                // Show AllMaintenanceView
                                if let vehicleID = vehicleViewModel.activeVehicleID {
                                    // We'll need to add a state variable for this
                                    // For now, this is handled by the sheet in MaintenanceView
                                }
                            } else {
                                isShowingPayWall = true
                            }
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

// MARK: - Preview with mock data
@MainActor
private func makePreviewContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Vehicle.self, FuelUsage.self, Maintenance.self, Mileage.self,
        configurations: config
    )
    let context = container.mainContext
    
    let calendar = Calendar.current
    let purchaseDate = calendar.date(byAdding: .year, value: -2, to: Date())!
    let productionDate = calendar.date(byAdding: .year, value: -3, to: Date())!
    
    let vehicle = Vehicle(
        name: "My Volkswagen Golf",
        fuelType: .liquid,
        purchaseDate: purchaseDate,
        manufacturingDate: productionDate,
        photo: nil,
        isPurchased: true
    )
    context.insert(vehicle)
    
    // Mileages for fuel consumption calculation
    let m1 = Mileage(value: 85_000, date: calendar.date(byAdding: .day, value: -60, to: Date())!, vehicle: vehicle)
    let m2 = Mileage(value: 85_400, date: calendar.date(byAdding: .day, value: -45, to: Date())!, vehicle: vehicle)
    let m3 = Mileage(value: 85_800, date: calendar.date(byAdding: .day, value: -30, to: Date())!, vehicle: vehicle)
    let m4 = Mileage(value: 86_250, date: calendar.date(byAdding: .day, value: -15, to: Date())!, vehicle: vehicle)
    context.insert(m1)
    context.insert(m2)
    context.insert(m3)
    context.insert(m4)
    vehicle.mileages = [m1, m2, m3, m4]
    
    // Fuel usages
    let fuel1 = FuelUsage(liters: 42.5, cost: 85.00, date: m2.date, mileage: m2, vehicle: vehicle)
    let fuel2 = FuelUsage(liters: 38.0, cost: 76.00, date: m3.date, mileage: m3, vehicle: vehicle)
    let fuel3 = FuelUsage(liters: 45.2, cost: 92.50, date: m4.date, mileage: m4, vehicle: vehicle)
    context.insert(fuel1)
    context.insert(fuel2)
    context.insert(fuel3)
    vehicle.fuelUsages = [fuel1, fuel2, fuel3]
    
    // Maintenances
    let maint1 = Maintenance(type: .oilChange, cost: 89.00, isFree: false, date: calendar.date(byAdding: .month, value: -3, to: Date())!, vehicle: vehicle)
    let maint2 = Maintenance(type: .tires, cost: 0, isFree: true, date: calendar.date(byAdding: .month, value: -6, to: Date())!, vehicle: vehicle)
    context.insert(maint1)
    context.insert(maint2)
    vehicle.maintenances = [maint1, maint2]
    
    try! context.save()
    return container
}

#Preview("Active Vehicle - With Data") {
    let container = makePreviewContainer()
    let viewModel = VehicleViewModel()
    return NavigationStack {
        ActiveVehicleContent(
            vehicleViewModel: viewModel,
            showAddFuelSheet: .constant(false),
            showAddMaintenanceSheet: .constant(false),
            showEditVehicleSheet: .constant(false),
            isShowingPayWall: .constant(false)
        )
    }
    .modelContainer(container)
}

#Preview("Active Vehicle - With Offer Banner") {
    let container = makePreviewContainer()
    let viewModel = VehicleViewModel()
    return NavigationStack {
        ActiveVehicleContent(
            vehicleViewModel: viewModel,
            showAddFuelSheet: .constant(false),
            showAddMaintenanceSheet: .constant(false),
            showEditVehicleSheet: .constant(false),
            isShowingPayWall: .constant(false),
            forceShowOfferBanner: true
        )
    }
    .modelContainer(container)
}

#Preview("Active Vehicle - Empty State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Vehicle.self, FuelUsage.self, Maintenance.self, Mileage.self,
        configurations: config
    )
    let viewModel = VehicleViewModel()
    return NavigationStack {
        ActiveVehicleContent(
            vehicleViewModel: viewModel,
            showAddFuelSheet: .constant(false),
            showAddMaintenanceSheet: .constant(false),
            showEditVehicleSheet: .constant(false),
            isShowingPayWall: .constant(false)
        )
    }
    .modelContainer(container)
}
