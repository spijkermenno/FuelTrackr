//
//  MaintenanceHistorySectionView.swift
//  FuelTrackr
//
//  Section displaying maintenance history with entries
//

import SwiftUI

public struct MaintenanceHistorySectionView: View {
    @Environment(\.colorScheme) private var colorScheme
    let entries: [MaintenanceEntryUiModel]
    let onAdd: () -> Void
    let onShowMore: () -> Void
    
    let doesMaintenanceOverviewExist = false
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(NSLocalizedString("maintenance_history", comment: "Maintenance History"))
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
                        .cornerRadius(20)
                }
            }
            
            // Entries
            if entries.isEmpty {
                Text(NSLocalizedString("maintenance_no_content", comment: "No maintenance entries"))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.onSurface)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 16) {
                    ForEach(entries.prefix(3)) { entry in
                        MaintenanceEntryView(entry: entry)
                    }
                }
            }
            
            // Show more button
            if entries.count > 3 && doesMaintenanceOverviewExist {
                Button(action: onShowMore) {
                    Text(NSLocalizedString("show_more", comment: "Show More"))
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
