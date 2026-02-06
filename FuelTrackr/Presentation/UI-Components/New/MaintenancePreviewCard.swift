//
//  MaintenancePreviewCard.swift
//  Presentation
//
//  Shows the three most recent maintenance entries in a card that visually
//  matches the FuelUsagePreviewCard.
//
//  Updated inline header/content (no extra properties) – 03 Jun 2025.
//

import SwiftUI
import Domain

// MARK: - UI-Model

public struct MaintenancePreviewUiModel: Identifiable {
    public let id: UUID
    public let date: Date
    public let type: MaintenanceType
    public let cost: Double
    public let notes: String?
    public let isFree: Bool

    public init(
        id: UUID = UUID(),
        date: Date,
        type: MaintenanceType,
        cost: Double,
        notes: String? = nil,
        isFree: Bool
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.cost = cost
        self.notes = notes
        self.isFree = isFree
    }
}

// MARK: - Card

public struct MaintenancePreviewCard: View {
    public let items: [MaintenancePreviewUiModel]
    public let onAdd: () -> Void
    public let onShowMore: () -> Void

    public init(
        items: [MaintenancePreviewUiModel],
        onAdd: @escaping () -> Void,
        onShowMore: @escaping () -> Void
    ) {
        self.items = items
        self.onAdd = onAdd
        self.onShowMore = onShowMore
    }

    public var body: some View {
        Card(
            header: {
                HStack {
                    Text(NSLocalizedString("maintenance_title", comment: ""))
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button(NSLocalizedString("add", comment: "")) { onAdd() }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Theme.colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
                .padding(.horizontal)
            },
            content: {
                VStack(spacing: 12) {
                    Divider()

                    if items.isEmpty {
                        Text(NSLocalizedString("maintenance_no_content", comment: ""))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(items.prefix(3)) { item in
                            MaintenancePreviewRow(model: item)
                        }
                    }
                }
                .padding(.horizontal)
            }
        )
    }
}

// MARK: - Row

private struct MaintenancePreviewRow: View {
    let model: MaintenancePreviewUiModel

    var body: some View {
        VStack(spacing: 6) {
            Text(model.date.formatted(date: .abbreviated, time: .omitted))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text(costString)
                    .font(.system(size: 16, weight: .regular))
                Spacer()
                Text(icon)
                    .font(.system(size: 24))
            }
            if let notes = model.notes, !notes.isEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity)
    }

    private var costString: String {
        if model.isFree {
            return NSLocalizedString("free_or_warranty", comment: "")
        }
        let costText = model.cost.formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
        return costText
    }

    private var icon: String {
        switch model.type {
        case .tires: return "🛞"
        case .distributionBelt: return "⚙️"
        case .oilChange: return "🛢"
        case .brakes: return "🛑"
        case .other: return "🔧"
        }
    }
}

// MARK: - Preview

#Preview {
    let samples = [
        MaintenancePreviewUiModel(date: .now, type: .oilChange, cost: 189.0, notes: nil, isFree: false),
        MaintenancePreviewUiModel(date: Calendar.current.date(byAdding: .day, value: -30, to: .now)!, type: .brakes, cost: 0, notes: "Warranty replacement", isFree: true),
        MaintenancePreviewUiModel(date: Calendar.current.date(byAdding: .day, value: -75, to: .now)!, type: .tires, cost: 450, notes: "Winter tires", isFree: false)
    ]
    return MaintenancePreviewCard(items: samples, onAdd: {}, onShowMore: {})
        .padding()
        .background(Color.gray.opacity(0.2))
}
