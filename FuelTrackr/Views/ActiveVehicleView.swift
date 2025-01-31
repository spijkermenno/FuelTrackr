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
    @State private var showAddMaintenanceSheet = false
    @State private var showEditVehicleSheet = false
    
    private let repository = SettingsRepository()
    
    var body: some View {
        guard let vehicle = viewModel.activeVehicle else {
            return AnyView(Text("No active vehicle found.").foregroundColor(.primary))
        }
        
        let isMetric = repository.isUsingMetric()
        
        return AnyView(
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let photoData = vehicle.photo, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fill)
                            .frame(maxHeight: 250)
                            .background(Color.secondary)
                            .cornerRadius(15)
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                    
                    VehiclePurchaseBanner(
                        isPurchased: vehicle.isPurchased,
                        purchaseDate: vehicle.purchaseDate,
                        onConfirmPurchase: {
//                            vehicle.isPurchased = true
//                            viewModel.updateVehiclePurchaseStatus(isPurchased: true, context: context)
                            showEditVehicleSheet = true
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        detailRow(label: NSLocalizedString("license_plate_label", comment: ""), value: vehicle.licensePlate)
                        detailRow(
                            label: NSLocalizedString("mileage_label", comment: ""),
                            value: "\(convertMileage(vehicle.mileage, isMetric: isMetric)) \(isMetric ? "km" : "mi")"
                        )
                        detailRow(label: NSLocalizedString("purchase_date_label", comment: ""), value: vehicle.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                        detailRow(label: NSLocalizedString("manufacturing_date_label", comment: ""), value: vehicle.manufacturingDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    
                    FuelUsageView(viewModel: viewModel, showAddFuelSheet: $showAddFuelSheet, isVehicleActive: vehicle.isPurchased)
                    
                    MaintenanceView(viewModel: viewModel, showAddMaintenanceSheet: $showAddMaintenanceSheet, isVehicleActive: vehicle.isPurchased)
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle(vehicle.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showEditVehicleSheet = true
                    }) {
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
            .sheet(isPresented: $showAddFuelSheet) {
                AddFuelUsageSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddMaintenanceSheet) {
                AddMaintenanceSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showEditVehicleSheet) {
                EditVehicleSheet(viewModel: viewModel)
            }
        )
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
    
    private func convertMileage(_ mileage: Int, isMetric: Bool) -> Int {
        isMetric ? mileage : Int(Double(mileage) / 1.609)
    }
}
