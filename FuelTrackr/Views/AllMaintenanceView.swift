import SwiftUI

struct AllMaintenanceView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.modelContext) private var context
    @State private var maintenanceToDelete: Maintenance? = nil
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            List {
                if let maintenances = viewModel.activeVehicle?.maintenances.sorted(by: { $0.date > $1.date }),
                   !maintenances.isEmpty {
                    ForEach(Array(maintenances.enumerated()), id: \.element) { index, maintenance in
                        AllMaintenanceRow(maintenance: maintenance, colorIndex: index)
                            .listRowSeparator(.hidden)
                            .padding(0)
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first,
                           let maintenances = viewModel.activeVehicle?.maintenances.sorted(by: { $0.date > $1.date }) {
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
                        .listRowSeparator(.hidden)
                    
                    AllSkeletonMaintenanceRow(colorIndex: 0)
                        .listRowSeparator(.hidden)
                    AllSkeletonMaintenanceRow(colorIndex: 1)
                        .listRowSeparator(.hidden)
                    AllSkeletonMaintenanceRow(colorIndex: 0)
                        .listRowSeparator(.hidden)
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle(NSLocalizedString("maintenance_list_title", comment: ""))
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

struct AllMaintenanceRow: View {
    let maintenance: Maintenance
    let colorIndex: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                // Display the maintenance date.
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
                
                // Additional information (days ago and mileage if available).
                HStack(spacing: 8) {
                    Text("\(maintenance.isFree ? NSLocalizedString("free_or_warranty", comment: "Maintenance is free") : String(format: "€%.2f", maintenance.cost))")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(daysAgoText())
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    if let mileageValue = maintenance.mileage?.value {
                        Text("\(mileageValue) km")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            Spacer()
            // Display the maintenance type icon as an emoji.
            Text(maintenanceIcon(for: maintenance.type))
                .font(.system(size: 40))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorIndex.isMultiple(of: 2) ? Color.clear : Color(UIColor.systemGray6))
    }
    
    private func daysAgoText() -> String {
        let daysAgo = Calendar.current.dateComponents([.day], from: maintenance.date, to: Date()).day ?? 0
        return "\(daysAgo) " + NSLocalizedString("days_ago", comment: "Days ago maintenance was performed")
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

struct AllSkeletonMaintenanceRow: View {
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
        .background(colorIndex.isMultiple(of: 2) ? Color.gray.opacity(0) : Color(UIColor.systemGray6))
        .onAppear {
            isAnimating = true
        }
    }
}
