// MARK: - Package: Presentation

//
//  AllMaintenanceView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain
import SwiftData

public struct AllMaintenanceView: View {
    @Environment(\.modelContext) var context

    public let vehicleID: PersistentIdentifier

    @State private var vehicle: Vehicle?
    @State private var maintenanceToDelete: Maintenance? = nil
    @State private var showDeleteConfirmation = false

    public init(vehicleID: PersistentIdentifier) {
        self.vehicleID = vehicleID
    }

    public var body: some View {
        NavigationView {
            List {
                if let maintenances = vehicle?.maintenances.sorted(by: { $0.date > $1.date }), !maintenances.isEmpty {
                    ForEach(Array(maintenances.enumerated()), id: \.element) { index, maintenance in
                        AllMaintenanceRow(maintenance: maintenance, colorIndex: index)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 8)
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            maintenanceToDelete = maintenances[index]
                            showDeleteConfirmation = true
                        }
                    }
                } else {
                    EmptyStateView()
                }
            }
            .background(Color(UIColor.systemBackground))
            .listStyle(.plain)
            .navigationTitle(NSLocalizedString("maintenance_list_title", comment: ""))
            .confirmationDialog(
                NSLocalizedString("delete_confirmation_title", comment: ""),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete_confirmation_delete", comment: ""), role: .destructive) {
                    if let maintenance = maintenanceToDelete {
                        context.delete(maintenance)
                    }
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            }
        }
        .onAppear {
            resolveVehicle()
        }
    }

    private func resolveVehicle() {
        do {
            vehicle = try context.model(for: vehicleID) as? Vehicle
        } catch {
            print("⚠️ Failed to resolve vehicle: \(error)")
            vehicle = nil
        }
    }
}

// MARK: - Maintenance Row

public struct AllMaintenanceRow: View {
    public let maintenance: Maintenance
    public let colorIndex: Int

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(maintenance.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundColor(.secondary)

                if let notes = maintenance.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.primary)
                } else {
                    Text(maintenance.type.localized)
                        .font(.body)
                        .foregroundColor(.primary)
                }

                HStack(spacing: 8) {
                    CostBadge(text: maintenance.isFree ? NSLocalizedString("free_or_warranty", comment: "") : String(format: "€%.2f", maintenance.cost))
                    DaysAgoBadge(date: maintenance.date)

                    if let mileage = maintenance.mileage?.value {
                        MileageBadge(mileage: mileage)
                    }
                }
            }

            Spacer()

            Text(maintenanceIcon(for: maintenance.type))
                .font(.system(size: 40))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorIndex.isMultiple(of: 2) ? Color.clear : Color(UIColor.systemGray6))
        .cornerRadius(12)
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

// MARK: - Badges

public struct CostBadge: View {
    public let text: String

    public var body: some View {
        Text(text)
            .font(.caption)
            .padding(8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.orange)
    }
}

public struct DaysAgoBadge: View {
    public let date: Date

    public var body: some View {
        let daysAgo = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return Text("\(daysAgo) " + NSLocalizedString("days_ago", comment: ""))
            .font(.caption)
            .padding(8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.orange)
    }
}

public struct MileageBadge: View {
    public let mileage: Int

    public var body: some View {
        Text("\(mileage) km")
            .font(.caption)
            .padding(8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.orange)
    }
}

// MARK: - Empty State

public struct EmptyStateView: View {
    public var body: some View {
        VStack(spacing: 16) {
            Text(NSLocalizedString("maintenance_no_content", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()

            ForEach(0..<3) { index in
                AllSkeletonMaintenanceRow(colorIndex: index)
                    .listRowSeparator(.hidden)
            }
        }
    }
}

// MARK: - Skeleton View

public struct AllSkeletonMaintenanceRow: View {
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
        .background(colorIndex.isMultiple(of: 2) ? Color.clear : Color(UIColor.systemGray6))
        .onAppear { isAnimating = true }
    }
}
