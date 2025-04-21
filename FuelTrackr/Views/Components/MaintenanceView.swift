//
//  MaintenanceView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

// MARK: - MaintenanceView

struct MaintenanceView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAddMaintenanceSheet: Bool
    var isVehicleActive: Bool
    @State private var showAllMaintenanceEntries = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(NSLocalizedString("maintenance_title", comment: ""))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showAddMaintenanceSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(NSLocalizedString("add", comment: ""))
                    }
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isVehicleActive ? Color.orange : Color.gray.opacity(0.5))
                    .cornerRadius(8)
                }
                .disabled(!isVehicleActive)
                
                Button(action: {
                    showAllMaintenanceEntries = true
                }) {
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isVehicleActive ? Color.orange : Color.gray.opacity(0.5))
                        .cornerRadius(8)
                }
                .disabled(!isVehicleActive)
            }
            
            // List view
            MaintenanceListView(viewModel: viewModel, showAllMaintenanceEntries: $showAllMaintenanceEntries)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .sheet(isPresented: $showAllMaintenanceEntries) {
            AllMaintenanceView(viewModel: viewModel)
        }
    }
}

// MARK: - MaintenanceListView

struct MaintenanceListView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAllMaintenanceEntries: Bool

    var body: some View {
        if let maintenances = viewModel.activeVehicle?.maintenances.sorted(by: { $0.date > $1.date }),
           !maintenances.isEmpty {
            // Limit to a maximum of 3 entries
            let latestEntries = Array(maintenances.prefix(3))
            
            VStack(alignment: .leading) {
                ForEach(Array(latestEntries.enumerated()), id: \.element) { index, maintenance in
                    MaintenanceRow(maintenance: maintenance, colorIndex: index)
                }
                
                // If there are fewer than 3 entries, add skeleton rows to fill the space.
                if maintenances.count < 2 {
                    SkeletonMaintenanceRow(colorIndex: maintenances.count)
                    SkeletonMaintenanceRow(colorIndex: maintenances.count + 1)
                } else if maintenances.count < 3 {
                    SkeletonMaintenanceRow(colorIndex: maintenances.count)
                }
                
                Spacer()
            }
        } else {
            Text(NSLocalizedString("maintenance_no_content", comment: ""))
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - MaintenanceRow

struct MaintenanceRow: View {
    let maintenance: Maintenance
    let colorIndex: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(maintenance.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text("\(maintenance.type.localized): \(maintenance.isFree ? NSLocalizedString("free_or_warranty", comment: "Maintenance is free") : String(format: "€%.2f", maintenance.cost))")
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let notes = maintenance.notes {
                    Text(notes)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(maintenanceIcon(for: maintenance.type))
                .font(.system(size: 40))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 75, alignment: .leading)
        .background(colorIndex.isMultiple(of: 2) ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
    }
    
    private func maintenanceIcon(for type: MaintenanceType) -> String {
        switch type {
        case .tires:
            return "🛞"
        case .distributionBelt:
            return "⚙️"
        case .oilChange:
            return "🛢"
        case .brakes:
            return "🛑"
        case .other:
            return "🔧"
        }
    }
}

// MARK: - SkeletonMaintenanceRow

struct SkeletonMaintenanceRow: View {
    let colorIndex: Int
    @State private var isAnimating = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 10)
                    .shimmerEffect(isAnimating: isAnimating)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 12)
                    .shimmerEffect(isAnimating: isAnimating)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 10)
                    .shimmerEffect(isAnimating: isAnimating)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .shimmerEffect(isAnimating: isAnimating)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 75, alignment: .leading)
        .background(colorIndex.isMultiple(of: 2) ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
        .onAppear {
            isAnimating = true
        }
    }
}
