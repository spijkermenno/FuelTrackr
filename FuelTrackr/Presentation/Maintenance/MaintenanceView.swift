// MARK: - Package: Presentation

//
//  MaintenanceView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI
import Domain

public struct MaintenanceView: View {
    @Environment(\.modelContext) var context
    @ObservedObject var viewModel: VehicleViewModel

    @Binding public var showAddMaintenanceSheet: Bool
    public var isVehicleActive: Bool

    @State private var showAllMaintenanceEntries = false
    @State private var resolvedVehicle: Vehicle?

    public init(
        viewModel: VehicleViewModel,
        showAddMaintenanceSheet: Binding<Bool>,
        isVehicleActive: Bool
    ) {
        _showAddMaintenanceSheet = showAddMaintenanceSheet
        self.isVehicleActive = isVehicleActive
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if let vehicle = resolvedVehicle {
                MaintenanceListView(vehicle: vehicle, showAllMaintenanceEntries: $showAllMaintenanceEntries)
            } else {
                Text(NSLocalizedString("maintenance_no_content", comment: ""))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .sheet(isPresented: $showAllMaintenanceEntries) {
            if InAppPurchaseManager.shared.hasActiveSubscription {
                if let vehicleID = viewModel.activeVehicleID {
                    AllMaintenanceView(vehicleID: vehicleID)
                } else {
                    EmptyView()
                }
            } else {
                InAppPurchasePayWall()
            }
        }
        .onAppear {
            resolvedVehicle = viewModel.resolvedVehicle(context: context)
        }
    }

    private var header: some View {
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
    }
}

public struct MaintenanceListView: View {
    public let vehicle: Vehicle
    @Binding public var showAllMaintenanceEntries: Bool

    public var body: some View {
        let maintenances = vehicle.maintenances.sorted(by: { $0.date > $1.date })

        if !maintenances.isEmpty {
            VStack(alignment: .leading) {
                ForEach(Array(maintenances.prefix(3).enumerated()), id: \.element) { index, maintenance in
                    MaintenanceRow(maintenance: maintenance, colorIndex: index)
                }

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

public struct MaintenanceRow: View {
    public let maintenance: Maintenance
    public let colorIndex: Int

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(maintenance.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Text("\(maintenance.type.localized): \(maintenance.isFree ? NSLocalizedString("free_or_warranty", comment: "Free maintenance") : String(format: "€%.2f", maintenance.cost))")
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
        case .tires: return "🛞"
        case .distributionBelt: return "⚙️"
        case .oilChange: return "🛢"
        case .brakes: return "🛑"
        case .other: return "🔧"
        }
    }
}

public struct SkeletonMaintenanceRow: View {
    public let colorIndex: Int
    @State private var isAnimating = false

    public var body: some View {
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
