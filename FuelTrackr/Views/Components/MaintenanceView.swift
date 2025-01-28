//
//  MaintenanceView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

struct MaintenanceView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAddMaintenanceSheet: Bool
    @State private var showAllMaintenanceEntries = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(NSLocalizedString("maintenance_title", comment: "Maintenance Records"))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    showAddMaintenanceSheet = true
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

            if let maintenances = viewModel.activeVehicle?.maintenances.sorted(by: { $0.date > $1.date }), !maintenances.isEmpty {
                let latestEntries = Array(maintenances.prefix(3))

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(latestEntries, id: \.self) { maintenance in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                // Date
                                Text(maintenance.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                // Type and Cost
                                Text("\(maintenance.type.rawValue): €\(maintenance.cost, specifier: "%.2f")")
                                    .font(.body)
                                // Notes
                                if let notes = maintenance.notes {
                                    Text(notes)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: maintenanceIcon(for: maintenance.type))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }

                    if maintenances.count > 3 {
                        Button(action: {
                            showAllMaintenanceEntries = true
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
                }
            } else {
                Text(NSLocalizedString("maintenance_no_content", comment: "No maintenance records available"))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .sheet(isPresented: $showAllMaintenanceEntries) {
            AllMaintenanceView(viewModel: viewModel)
        }
    }

    // MARK: - Helper Method to Get Icon for Maintenance Type
    private func maintenanceIcon(for type: MaintenanceType) -> String {
        switch type {
        case .tires:
            return "tire" // Icon for tires
        case .distributionBelt:
            return "gearshape.circle" // Icon for distribution belt
        case .oilChange:
            return "oilcan.fill" // Icon for oil change
        case .brakes:
            return "exclamationmark.brakesignal" // Icon for brakes
        case .other:
            return "wrench.and.screwdriver.fill" // Icon for other
        }
    }
}
