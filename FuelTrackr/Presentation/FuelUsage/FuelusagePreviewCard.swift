//
//  FuelUsagePreviewCard.swift
//  FuelTrackr
//

import SwiftUI
import Domain
import SwiftData

public struct FuelUsagePreviewUiModel: Identifiable {
    public let id: UUID
    public let fuelUsageID: PersistentIdentifier
    public let date: Date
    public let liters: Double
    public let cost: Double
    public let economy: Double
    
    public init(
        id: UUID = UUID(),
        fuelUsageID: PersistentIdentifier,
        date: Date,
        liters: Double,
        cost: Double,
        economy: Double
    ) {
        self.id = id
        self.fuelUsageID = fuelUsageID
        self.date = date
        self.liters = liters
        self.cost = cost
        self.economy = economy
    }
}

public struct FuelUsagePreviewCard: View {
    let items: [FuelUsagePreviewUiModel]
    let onAdd: () -> Void
    let onShowMore: () -> Void
    let onEdit: (FuelUsagePreviewUiModel) -> Void
    
    public init(
        items: [FuelUsagePreviewUiModel],
        onAdd: @escaping () -> Void,
        onShowMore: @escaping () -> Void,
        onEdit: @escaping (FuelUsagePreviewUiModel) -> Void
    ) {
        self.items = items
        self.onAdd = onAdd
        self.onShowMore = onShowMore
        self.onEdit = onEdit
    }
    
    // Adjust if your rows are taller/shorter
    private let rowHeight: CGFloat = 56
    
    public var body: some View {
        Card(
            header: {
                HStack {
                    Text(NSLocalizedString("fuel_usage_title", comment: ""))
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button(NSLocalizedString("add", comment: "")) {
                        onAdd()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Theme.colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(24)
                    .accessibilityLabel(Text(NSLocalizedString("add", comment: "")))
                }
                .padding(.horizontal)
            },
            content: {
                VStack(spacing: 12) {
                    Divider()
                    
                    // Native drag-to-reveal swipe actions require List
                    List {
                        ForEach(items) { item in
                            FuelUsagePreviewRow(model: item) {
                                onEdit(item)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollDisabled(true) // keep outer scroll view in control
                    .frame(height: rowHeight * CGFloat(items.count))
                    .background(Color.clear)
                }
                .padding(.horizontal)
            }
        )
    }
}

private struct FuelUsagePreviewRow: View {
    @EnvironmentObject private var settings: SettingsViewModel
    let model: FuelUsagePreviewUiModel
    var onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            Text(model.date.formatted(date: .abbreviated, time: .omitted))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(volumeCostString)
                    .font(.system(size: 16, weight: .regular))
                Spacer()
                Text(economyString)
                    .font(.system(size: 16, weight: .regular))
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        // Native iOS swipe action (drag to reveal)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                onEdit()
            } label: {
                Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil").tint(Theme.colors.primary)
            }
            .tint(Color.red.opacity(0))
        }
        // Optional: context menu as an alternative entry point
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                    .tint(Theme.colors.primary)
            }
            .tint(Color.red.opacity(0))
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: Text(NSLocalizedString("edit", comment: ""))) {
            onEdit()
        }
    }
    
    private var volumeCostString: String {
        let costText = model.cost.formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
        if settings.isUsingMetric {
            let litersText = String(format: "%.2f L", model.liters)
            return "\(litersText) - \(costText)"
        } else {
            let gallons = model.liters * 0.264172
            let gallonsText = String(format: "%.2f G", gallons)
            return "\(gallonsText) - \(costText)"
        }
    }
    
    private var economyString: String {
        if settings.isUsingMetric {
            return String(format: "%.2f km/l", model.economy)
        } else {
            let mpg = model.economy * 2.35215
            return String(format: "%.2f mpg", mpg)
        }
    }
}
