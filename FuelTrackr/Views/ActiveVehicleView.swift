//
//  ActiveVehicleView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import FirebaseAnalytics

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
            Analytics.logEvent("no_active_vehicle", parameters: nil)
            return AnyView(Text("No active vehicle found.").foregroundColor(.primary))
        }

        Analytics.logEvent("active_vehicle_found", parameters: [
            "vehicle_name": vehicle.name,
            "license_plate": vehicle.licensePlate
        ])

        let isMetric = repository.isUsingMetric()
        let latestMileage = vehicle.mileages.first?.value ?? 0
        
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
                            showEditVehicleSheet = true
                        }
                    )

                    VehicleInfoView(viewModel: viewModel)

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

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
