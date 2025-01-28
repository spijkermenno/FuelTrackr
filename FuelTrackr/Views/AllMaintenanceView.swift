//
//  AllMaintenanceView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

struct AllMaintenanceView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.modelContext) private var context
    @State private var maintenanceToDelete: Maintenance? = nil // Track item to delete
    @State private var showDeleteConfirmation = false // Control confirmation dialog

    var body: some View {
        NavigationView {
            List {
                if let maintenances = viewModel.activeVehicle?.maintenances.sorted(by: { $0.date > $1.date }) {
                    ForEach(maintenances, id: \.self) { maintenance in
                        VStack(alignment: .leading, spacing: 4) {
                            // Maintenance Date
                            Text(maintenance.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.footnote)
                                .foregroundColor(.secondary)

                            // Maintenance Type and Cost
                            Text("\(maintenance.type.rawValue): €\(maintenance.cost, specifier: "%.2f")")
                                .font(.body)

                            // Maintenance Notes
                            if let notes = maintenance.notes {
                                Text(notes)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            maintenanceToDelete = maintenances[index]
                            showDeleteConfirmation = true
                        }
                    }
                } else {
                    Text(NSLocalizedString("maintenance_no_content", comment: "Maintenance information has no content"))
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .navigationTitle(NSLocalizedString("maintenance_list_title", comment: "Maintenance list title"))
            .listStyle(PlainListStyle())
            .confirmationDialog(
                NSLocalizedString("delete_confirmation_title", comment: "Delete Confirmation"),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete_confirmation_delete", comment: "Delete"), role: .destructive) {
                    if let maintenance = maintenanceToDelete {
                        viewModel.deleteMaintenance(context: context, maintenance: maintenance)
                    }
                }
                Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) {}
            }
        }
    }
}
