//
//  ActiveVehicleView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI

struct ActiveVehicleView: View {
    let vehicle: Vehicle
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false // State for confirmation dialog
    var onDelete: () -> Void // Callback for dismissal

    var body: some View {
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
                    detailRow(label: NSLocalizedString("mileage_label", comment: "Label for mileage"), value: "\(vehicle.mileage) km")
                    detailRow(label: NSLocalizedString("purchase_date_label", comment: "Label for purchase date"), value: vehicle.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                    detailRow(label: NSLocalizedString("manufacturing_date_label", comment: "Label for manufacturing date"), value: vehicle.manufacturingDate.formatted(date: .abbreviated, time: .omitted))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                // Fuel History
                FuelInformationView()
                
                // Maintenance
                MaintenanceHistoryView()
                
                // Delete Button
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text(NSLocalizedString("delete_vehicle_button", comment: "Button to delete the vehicle"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .confirmationDialog(
                    NSLocalizedString("delete_confirmation_title", comment: "Title for delete confirmation dialog"),
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button(NSLocalizedString("delete_confirmation_delete", comment: "Delete confirmation option"), role: .destructive, action: onDelete)
                    Button(NSLocalizedString("delete_confirmation_cancel", comment: "Cancel confirmation option"), role: .cancel) {}
                }
            }
            .padding()
        }
        .navigationTitle(vehicle.name)
        .navigationBarTitleDisplayMode(.large)
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
}

struct FuelInformationView: View {
    // ===== TESTING ONLY =====
    
    @State private var fuelUsageClickCount = 0 // Counter to toggle views
    @State private var showTestData = false   // Flag to display test data
    
    // ========================
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(NSLocalizedString("fuel_usage_title", comment: "Fuel usage information"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // Add new Fuel entry
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(NSLocalizedString("add", comment: "Add button label"))
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
            }
            
            if showTestData {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<3) { _ in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("January 24, 2025") // Example date
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Text("50 liters, €75.00") // Example data
                                    .font(.body)
                            }
                            Spacer()
                            Text("12345 km") // Example mileage
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                }
            } else {
                Text(NSLocalizedString("fuel_usage_no_content", comment: "Fuel usage information has no content"))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        fuelUsageClickCount += 1
                        if fuelUsageClickCount == 3 {
                            showTestData = true
                            fuelUsageClickCount = 0 // Reset the counter
                        }
                    }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct MaintenanceHistoryView: View {
    // ===== TESTING ONLY =====
    
    @State private var clickCount = 0 // Counter to toggle views
    @State private var showTestData = false   // Flag to display test data
    
    // ========================
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(NSLocalizedString("maintenance_title", comment: "Maintenance history information"))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    // Add new Maintenance entry
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(NSLocalizedString("add", comment: "Add button label"))
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
            }

            if showTestData {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<3) { _ in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("January 20, 2025") // Example date
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Text("Oil change, €150.00") // Example data
                                    .font(.body)
                            }
                            Spacer()
                            Image(systemName: "oilcan.fill")
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                                // Action to load more data
                            }) {
                                Text(NSLocalizedString("show_more", comment: "Show more maintenance records"))
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(10)
                            }
                            .padding(.top, 8)
                }
            } else {
                Text(NSLocalizedString("maintenance_no_content", comment: "Maintenance history has no content"))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        clickCount += 1
                        if clickCount == 3 {
                            showTestData = true
                            clickCount = 0 // Reset the counter
                        }
                    }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
