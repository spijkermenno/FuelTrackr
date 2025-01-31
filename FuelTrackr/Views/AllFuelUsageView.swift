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
    @State private var fuelToDelete: FuelUsage? = nil
    @State private var showDeleteConfirmation = false

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
                                .foregroundColor(.primary)
                            if usage.liters > 0 {
                                Text("\(NSLocalizedString("price_per_liter", comment: "")): €\(usage.cost / usage.liters, specifier: "%.2f")")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color(UIColor.secondarySystemBackground))
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            fuelToDelete = fuelUsages[index]
                            showDeleteConfirmation = true
                        }
                    }
                } else {
                    Text(NSLocalizedString("fuel_usage_no_content", comment: ""))
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle(NSLocalizedString("fuel_usage_list_title", comment: ""))
            .listStyle(PlainListStyle())
            .confirmationDialog(
                NSLocalizedString("delete_confirmation_title", comment: ""),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete_confirmation_delete", comment: ""), role: .destructive) {
                    if let fuelUsage = fuelToDelete {
                        viewModel.deleteFuelUsage(context: context, fuelUsage: fuelUsage)
                    }
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
        }
    }
}
