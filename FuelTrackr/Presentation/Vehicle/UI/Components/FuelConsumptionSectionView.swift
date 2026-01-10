//
//  FuelConsumptionSectionView.swift
//  FuelTrackr
//
//  Section displaying fuel consumption history with entries
//

import SwiftUI

public struct FuelConsumptionSectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    let entries: [FuelConsumptionEntryUiModel]
    let onAdd: () -> Void
    let onShowMore: () -> Void
    let onEdit: (FuelConsumptionEntryUiModel) -> Void
    let onPartialFillTapped: ((FuelConsumptionEntryUiModel) -> Void)?
    
    init(
        entries: [FuelConsumptionEntryUiModel],
        onAdd: @escaping () -> Void,
        onShowMore: @escaping () -> Void,
        onEdit: @escaping (FuelConsumptionEntryUiModel) -> Void,
        onPartialFillTapped: ((FuelConsumptionEntryUiModel) -> Void)? = nil
    ) {
        self.entries = entries
        self.onAdd = onAdd
        self.onShowMore = onShowMore
        self.onEdit = onEdit
        self.onPartialFillTapped = onPartialFillTapped
    }
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(NSLocalizedString("fuel_consumption", comment: "Fuel Consumption"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colors.onBackground)
                
                Spacer()
                
                Button(action: onAdd) {
                    Text(NSLocalizedString("add", comment: "Add"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.onPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(colors.primary)
                        .clipShape(Capsule())
                }
            }
            
            // Entries
            if entries.isEmpty {
                Text(NSLocalizedString("fuel_usage_no_content", comment: "No fuel entries"))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.onSurface)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                let displayedEntries = Array(entries.prefix(3))
                VStack(spacing: 0) {
                    ForEach(Array(displayedEntries.enumerated()), id: \.element.id) { index, entry in
                        FuelConsumptionEntryView(
                            entry: entry,
                            onEdit: {
                                onEdit(entry)
                            },
                            onPartialFillTapped: entry.containsPartialFills ? {
                                onPartialFillTapped?(entry)
                            } : nil
                        )
                        
                        if index < displayedEntries.count - 1 {
                            Divider()
                                .background(colors.divider)
                                .padding(.top, 12)
                                .padding(.bottom, 12)
                        }
                    }
                }
            }
            
            // Show more button or message
            if entries.count >= 2 {
                Button(action: onShowMore) {
                    Text(NSLocalizedString("fuel_history", comment: "Fuel History"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colors.primary, lineWidth: 1)
                        )
                        .cornerRadius(12)
                }
            } else if entries.count == 1 {
                Text(NSLocalizedString("fuel_history_need_more_data", comment: "Need more data for history"))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.onSurface)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            }
        }
        .padding(Theme.dimensions.spacingL)
        .background(colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 31))
        .overlay(
            RoundedRectangle(cornerRadius: 31)
                .stroke(colors.border, lineWidth: 1)
        )
    }
}
