//
//  ShowAllMaintenanceView.swift
//  DriveWise
//
//  Created by Menno Spijker on 27/01/2025.
//


//
//  ShowAllMaintenanceView.swift
//  DriveWise
//

import SwiftUI

struct ShowAllMaintenanceView: View {
    @ObservedObject var viewModel: VehicleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("all_maintenance_title", comment: "All Maintenance Records"))
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 8)

            if let maintenances = viewModel.activeVehicle?.maintenances.sorted(by: { $0.date > $1.date }), !maintenances.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(maintenances, id: \.self) { maintenance in
                            HStack(spacing: 12) {
                                // Icon
                                Image(systemName: maintenanceIcon(for: maintenance.type))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.black)

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
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                        }
                    }
                }
            } else {
                Text(NSLocalizedString("maintenance_no_content", comment: "No maintenance records available"))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .navigationTitle(NSLocalizedString("all_maintenance_title", comment: "All Maintenance"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper method to get icon for maintenance type
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