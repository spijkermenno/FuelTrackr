//
//  AllFuelUsageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

struct AllFuelUsageView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.modelContext) private var context
    @State private var fuelToDelete: FuelUsage? = nil // Track item to delete
    @State private var showDeleteConfirmation = false // Control confirmation dialog

    var body: some View {
        NavigationView {
            List {
                if let fuelUsages = viewModel.activeVehicle?.fuelUsages.sorted(by: { $0.date > $1.date }) {
                    ForEach(fuelUsages, id: \.self) { usage in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(usage.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Text("\(usage.liters, specifier: "%.2f") liters, €\(usage.cost, specifier: "%.2f")")
                                .font(.body)
                            if usage.liters > 0 {
                                Text("\(NSLocalizedString("price_per_liter", comment: "Price per liter")): €\(usage.cost / usage.liters, specifier: "%.2f")")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            fuelToDelete = fuelUsages[index]
                            showDeleteConfirmation = true
                        }
                    }
                } else {
                    Text(NSLocalizedString("fuel_usage_no_content", comment: "Fuel usage information has no content"))
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .navigationTitle(NSLocalizedString("fuel_usage_list_title", comment: "Fuel usage list title"))
            .listStyle(PlainListStyle())
            .confirmationDialog(
                NSLocalizedString("delete_confirmation_title", comment: "Delete Confirmation"),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete_confirmation_delete", comment: "Delete"), role: .destructive) {
                    if let fuelUsage = fuelToDelete {
                        viewModel.deleteFuelUsage(context: context, fuelUsage: fuelUsage)
                    }
                }
                Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) {}
            }
        }
    }
}
