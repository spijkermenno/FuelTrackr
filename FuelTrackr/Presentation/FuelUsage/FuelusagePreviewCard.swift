import SwiftUI
import Domain

public struct FuelUsagePreviewUiModel: Identifiable {
    public let id: UUID
    public let date: Date
    public let liters: Double
    public let cost: Double
    public let economy: Double
    
    public init(
        id: UUID = UUID(),
        date: Date,
        liters: Double,
        cost: Double,
        economy: Double
    ) {
        self.id = id
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
    
    public init(
        items: [FuelUsagePreviewUiModel],
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
                    Text(NSLocalizedString("fuel_usage_title", comment: ""))
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button(NSLocalizedString("add", comment: "")) {
                        onAdd()
                    }
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
                    ForEach(items) { item in
                        FuelUsagePreviewRow(model: item)
                    }
                    // TODO
                    
//                    Button(NSLocalizedString("fuel_usage_list_title", comment: "")) {
//                        onShowMore()
//                    }
//                    .padding(.top, 4)
//                    .font(.footnote)
//                    .foregroundColor(Theme.colors.primary)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
            }
        )
    }
}

private struct FuelUsagePreviewRow: View {
    @EnvironmentObject private var settings: SettingsViewModel
    let model: FuelUsagePreviewUiModel
    
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

#Preview {
    let settings = SettingsViewModel()
    settings.isUsingMetric = true
    let sample = [
        FuelUsagePreviewUiModel(date: .now, liters: 30.03, cost: 48.43, economy: 19.45),
        FuelUsagePreviewUiModel(date: Calendar.current.date(byAdding: .day, value: -7, to: .now)!, liters: 28.5, cost: 45.1, economy: 18.9),
        FuelUsagePreviewUiModel(date: Calendar.current.date(byAdding: .day, value: -17, to: .now)!, liters: 27.2, cost: 43.7, economy: 18.3)
    ]
    return FuelUsagePreviewCard(items: sample, onAdd: {}, onShowMore: {})
        .environmentObject(settings)
        .padding()
        .background(Color.gray.opacity(0.2))
}
