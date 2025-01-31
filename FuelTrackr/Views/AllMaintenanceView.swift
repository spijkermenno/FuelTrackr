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
    @State private var maintenanceToDelete: Maintenance? = nil
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            List {
                if let maintenances = viewModel.activeVehicle?.maintenances.sorted(by: { $0.date > $1.date }) {
                    ForEach(maintenances, id: \.self) { maintenance in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(maintenance.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.footnote)
                                .foregroundColor(.secondary)

                            Text("\(maintenance.type.rawValue): €\(maintenance.cost, specifier: "%.2f")")
                                .font(.body)
                                .foregroundColor(.primary)

                            if let notes = maintenance.notes {
                                Text(notes)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color(UIColor.secondarySystemBackground))
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            maintenanceToDelete = maintenances[index]
                            showDeleteConfirmation = true
                        }
                    }
                } else {
                    Text(NSLocalizedString("maintenance_no_content", comment: ""))
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle(NSLocalizedString("maintenance_list_title", comment: ""))
            .listStyle(PlainListStyle())
            .confirmationDialog(
                NSLocalizedString("delete_confirmation_title", comment: ""),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete_confirmation_delete", comment: ""), role: .destructive) {
                    if let maintenance = maintenanceToDelete {
                        viewModel.deleteMaintenance(context: context, maintenance: maintenance)
                    }
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
        }
    }
}
