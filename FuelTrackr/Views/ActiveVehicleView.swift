//
//  ActiveVehicleView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI

struct ActiveVehicleView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false
    @State private var showAddFuelSheet = false
    @State private var showAddMaintenanceSheet = false // State for maintenance sheet

    private let repository = SettingsRepository() // Access user settings

    var body: some View {
        guard let vehicle = viewModel.activeVehicle else {
            return AnyView(Text("No active vehicle found."))
        }

        let isMetric = repository.isUsingMetric() // Fetch the setting once

        return AnyView(
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Vehicle Photo Section
                    if let photoData = vehicle.photo, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fill)
                            .frame(maxHeight: 250)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    // Vehicle Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        detailRow(label: NSLocalizedString("license_plate_label", comment: "Label for license plate"), value: vehicle.licensePlate)
                        detailRow(
                            label: NSLocalizedString("mileage_label", comment: "Label for mileage"),
                            value: "\(convertMileage(vehicle.mileage, isMetric: isMetric)) \(isMetric ? "km" : "mi")"
                        )
                        detailRow(label: NSLocalizedString("purchase_date_label", comment: "Label for purchase date"), value: vehicle.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                        detailRow(label: NSLocalizedString("manufacturing_date_label", comment: "Label for manufacturing date"), value: vehicle.manufacturingDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Fuel History
                    FuelUsageView(viewModel: viewModel, showAddFuelSheet: $showAddFuelSheet)
                    
                    // Maintenance History
                    MaintenanceView(viewModel: viewModel, showAddMaintenanceSheet: $showAddMaintenanceSheet)
                }
                .padding()
            }
            .navigationTitle(vehicle.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsPageView(viewModel: viewModel)) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showAddFuelSheet) {
                AddFuelUsageSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddMaintenanceSheet) {
                AddMaintenanceSheet(viewModel: viewModel)
            }
        )
    }

    // MARK: - Detail Row
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Conversion Helper
    private func convertMileage(_ mileage: Int, isMetric: Bool) -> Int {
        isMetric ? mileage : Int(Double(mileage) / 1.609) // Convert km to mi if imperial
    }
}
