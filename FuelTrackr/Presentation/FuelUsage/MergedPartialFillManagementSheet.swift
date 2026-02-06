//
//  MergedPartialFillManagementSheet.swift
//  FuelTrackr
//
//  Created on 2025.
//

import SwiftUI
import Domain
import SwiftData

struct MergedPartialFillManagementSheet: View {
    let fuelUsageID: PersistentIdentifier // The last entry in the merged group
    let viewModel: VehicleViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var resolvedVehicle: Vehicle?
    @State private var mergedGroup: [FuelUsage] = []
    
    var onDismiss: () -> Void
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.dimensions.spacingL) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
                        Text(NSLocalizedString("partial_fill", comment: ""))
                            .font(Theme.typography.titleFont)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, Theme.dimensions.spacingSection)
                        
                        Text(NSLocalizedString("merged_partial_fill_description", comment: ""))
                            .font(Theme.typography.captionFont)
                            .foregroundColor(colors.onSurface)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Group Summary
                    if !mergedGroup.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.dimensions.spacingM) {
                            Text(NSLocalizedString("merged_group_summary", comment: ""))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(colors.onBackground)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(NSLocalizedString("total_fuel", comment: ""))
                                        .font(.system(size: 14))
                                        .foregroundColor(colors.onSurface)
                                    Text(String(format: "%.2f L", mergedGroup.reduce(0.0) { $0 + $1.liters }))
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(colors.onBackground)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(NSLocalizedString("entries_count", comment: ""))
                                        .font(.system(size: 14))
                                        .foregroundColor(colors.onSurface)
                                    Text("\(mergedGroup.count)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(colors.onBackground)
                                }
                            }
                        }
                        .padding(Theme.dimensions.spacingL)
                        .background(colors.surface)
                        .cornerRadius(Theme.dimensions.radiusCard)
                    }
                    
                    // Individual Entries
                    if !mergedGroup.isEmpty {
                        VStack(alignment: .leading, spacing: Theme.dimensions.spacingM) {
                            Text(NSLocalizedString("entries_in_group", comment: ""))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(colors.onBackground)
                            
                            let sortedGroup = mergedGroup.sorted { $0.date < $1.date }
                            VStack(spacing: 0) {
                                ForEach(Array(sortedGroup.enumerated()), id: \.element.persistentModelID) { index, usage in
                                    MergedGroupEntryRow(
                                        usage: usage,
                                        isCurrentEntry: false,
                                        viewModel: viewModel,
                                        onUpdate: {
                                            loadMergedGroup()
                                        }
                                    )
                                    
                                    // Connecting line between entries (except last)
                                    if index < sortedGroup.count - 1 {
                                        HStack {
                                            Circle()
                                                .fill(Color.orange.opacity(0.6))
                                                .frame(width: 4, height: 4)
                                            Rectangle()
                                                .fill(Color.orange.opacity(0.3))
                                                .frame(height: 1)
                                            Spacer()
                                        }
                                        .padding(.leading, Theme.dimensions.spacingM + 4)
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            .padding(Theme.dimensions.spacingM)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
                                    )
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, Theme.dimensions.spacingSection)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(colors.background)
            .navigationTitle(NSLocalizedString("partial_fill", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { onDismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(colors.onBackground)
                    }
                }
            }
            .onAppear {
                resolvedVehicle = viewModel.resolvedVehicle(context: context)
                loadMergedGroup()
            }
        }
    }
    
    private func loadMergedGroup() {
        guard let vehicle = resolvedVehicle else { return }
        let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
        
        // Find the group that contains the fuelUsageID
        if let group = groups.first(where: { group in
            group.contains { $0.persistentModelID == fuelUsageID }
        }) {
            mergedGroup = group
        }
    }
}

// MARK: - Merged Group Entry Row

struct MergedGroupEntryRow: View {
    let usage: FuelUsage
    let isCurrentEntry: Bool
    let viewModel: VehicleViewModel
    
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    
    var onUpdate: () -> Void
    
    init(
        usage: FuelUsage,
        isCurrentEntry: Bool = false,
        viewModel: VehicleViewModel,
        onUpdate: @escaping () -> Void
    ) {
        self.usage = usage
        self.isCurrentEntry = isCurrentEntry
        self.viewModel = viewModel
        self.onUpdate = onUpdate
    }
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    var body: some View {
        HStack(spacing: Theme.dimensions.spacingM) {
            // Visual indicator dot
            Circle()
                .fill(isCurrentEntry ? colors.primary : (usage.isPartialFill ? Color.orange : colors.primary.opacity(0.5)))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(formatDate(usage.date))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.onBackground)
                    
                    if isCurrentEntry {
                        Text("(\(NSLocalizedString("current", comment: "")))")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(colors.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(colors.primary.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(String(format: "%.2f L", usage.liters))
                        .font(.system(size: 12))
                        .foregroundColor(colors.onSurface)
                    
                    if let mileage = usage.mileage?.value {
                        Text("@ \(mileage) km")
                            .font(.system(size: 12))
                            .foregroundColor(colors.onSurface)
                    }
                }
            }
            
            Spacer()
            
            // Toggle button
            Button(action: {
                viewModel.updateFuelUsagePartialFillStatus(
                    id: usage.persistentModelID,
                    isPartialFill: !usage.isPartialFill,
                    context: context
                )
                onUpdate()
            }) {
                Text(usage.isPartialFill ? NSLocalizedString("partial_fill_badge", comment: "") : NSLocalizedString("full_fill", comment: ""))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(usage.isPartialFill ? Color.orange : colors.primary)
                    .cornerRadius(8)
            }
        }
        .padding(Theme.dimensions.spacingM)
        .background(
            isCurrentEntry 
                ? colors.primary.opacity(0.12) 
                : (usage.isPartialFill ? Color.orange.opacity(0.08) : colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isCurrentEntry 
                        ? colors.primary 
                        : (usage.isPartialFill ? Color.orange.opacity(0.5) : Color.clear), 
                    lineWidth: isCurrentEntry ? 2 : 1
                )
        )
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
}

