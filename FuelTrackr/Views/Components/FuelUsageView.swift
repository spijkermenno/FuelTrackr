//
//  FuelUsageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

struct FuelUsageView: View {
    @ObservedObject var viewModel: VehicleViewModel // Use the ViewModel
    @Binding var showAddFuelSheet: Bool // Binding to control the sheet from the parent
    @State private var showAllFuelEntries = false // Control showing all entries

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with title and "Add" button
            HStack {
                Text(NSLocalizedString("fuel_usage_title", comment: "Fuel usage information"))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    showAddFuelSheet = true // Trigger the sheet
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(NSLocalizedString("add", comment: "Add button label"))
                    }
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }

            // Display fuel entries or fallback content
            if let fuelUsages = viewModel.activeVehicle?.fuelUsages.sorted(by: { $0.date > $1.date }), !fuelUsages.isEmpty {
                let latestEntries = Array(fuelUsages.prefix(3)) // Show up to 3 entries

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(latestEntries, id: \.self) { usage in
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                // Entry Date
                                Text(usage.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.footnote)
                                    .foregroundColor(.secondary)

                                // Fuel and Cost Information
                                Text("\(usage.liters, specifier: "%.2f") liters, €\(usage.cost, specifier: "%.2f")")
                                    .font(.body)
                            }
                            Spacer()
                            // Price Per Liter
                            if usage.liters > 0 {
                                Text("€\(usage.cost / usage.liters, specifier: "%.2f")/L")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }

                    // Show more button if more than 3 entries
                    if fuelUsages.count > 3 {
                        Button(action: {
                            showAllFuelEntries = true // Navigate to detailed list
                        }) {
                            Text(NSLocalizedString("show_more", comment: "Show more fuel records"))
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
                }
            } else {
                // Fallback content for no data
                Text(NSLocalizedString("fuel_usage_no_content", comment: "Fuel usage information has no content"))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .sheet(isPresented: $showAllFuelEntries) {
            AllFuelUsageView(viewModel: viewModel) // Full list of fuel usage
        }
    }
}
