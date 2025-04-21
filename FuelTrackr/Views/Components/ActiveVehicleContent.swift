//
//  ActiveVehicleContent.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI

struct ActiveVehicleContent: View {
    var viewModel: VehicleViewModel
    var vehicle: Vehicle

    @Binding var showAddFuelSheet: Bool
    @Binding var showAddMaintenanceSheet: Bool
    @Binding var showEditVehicleSheet: Bool
    @Binding var showMonthlyRecapSheet: Bool

    @Environment(\.modelContext) private var context
    @EnvironmentObject var notificationHandler: NotificationHandler

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VehicleCarousel(viewModel: viewModel, photoData: vehicle.photo)
                VehiclePurchaseBanner(
                    isPurchased: vehicle.isPurchased,
                    purchaseDate: vehicle.purchaseDate,
                    onConfirmPurchase: { showEditVehicleSheet = true }
                )
                VehicleInfoView(viewModel: viewModel)
                FuelUsageView(viewModel: viewModel, showAddFuelSheet: $showAddFuelSheet, isVehicleActive: vehicle.isPurchased)
                MaintenanceView(viewModel: viewModel, showAddMaintenanceSheet: $showAddMaintenanceSheet, isVehicleActive: vehicle.isPurchased)
            }
            .padding()
        }
        .id(viewModel.refreshID)
        .background(Color(UIColor.systemBackground))
        .navigationTitle(vehicle.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showMonthlyRecapSheet = true }) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showEditVehicleSheet = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsPageView(viewModel: viewModel)) {
                    Image(systemName: "gear")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showAddFuelSheet, onDismiss: { viewModel.refresh(context: context) }) {
            AddFuelUsageSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddMaintenanceSheet, onDismiss: { viewModel.refresh(context: context) }) {
            AddMaintenanceSheet(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditVehicleSheet, onDismiss: { viewModel.refresh(context: context) }) {
            EditVehicleSheet(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showMonthlyRecapSheet) {
            MonthlyRecapSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $notificationHandler.shouldShowMonthlyRecapSheet) {
            MonthlyRecapSheet(viewModel: viewModel, showPreviousMonth: true)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}
