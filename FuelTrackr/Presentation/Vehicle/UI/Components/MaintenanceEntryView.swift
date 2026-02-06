//
//  MaintenanceEntryView.swift
//  FuelTrackr
//
//  Single maintenance entry row
//

import SwiftUI
import SwiftData
import Domain

public struct MaintenanceEntryUiModel: Identifiable {
    public let id: UUID
    public let maintenanceID: PersistentIdentifier
    public let date: Date
    public let type: MaintenanceType
    public let odometerAtMaintenance: Int
    public let cost: Double
    public let isFree: Bool
    
    public init(
        id: UUID = UUID(),
        maintenanceID: PersistentIdentifier,
        date: Date,
        type: MaintenanceType,
        odometerAtMaintenance: Int,
        cost: Double,
        isFree: Bool
    ) {
        self.id = id
        self.maintenanceID = maintenanceID
        self.date = date
        self.type = type
        self.odometerAtMaintenance = odometerAtMaintenance
        self.cost = cost
        self.isFree = isFree
    }
}

public struct MaintenanceEntryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsViewModel
    let entry: MaintenanceEntryUiModel
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formatDate(entry.date))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.onSurface)
                
                Text(entry.type.localizedString)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colors.onBackground)
                
                Text(formatOdometer(entry.odometerAtMaintenance))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.onSurface)
            }
            
            Spacer()
            
            Text(formatCost(entry.cost, isFree: entry.isFree))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(entry.isFree ? colors.success : colors.accentOrange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM yyyy" // e.g., "11 Juli 2025"
        return formatter.string(from: date)
    }
    
    private func formatOdometer(_ mileage: Int) -> String {
        if settings.isUsingMetric {
            return String(format: "%d km", mileage)
        } else {
            let miles = Int(Double(mileage) * 0.621371)
            return String(format: "%d mi", miles)
        }
    }
    
    private func formatCost(_ cost: Double, isFree: Bool) -> String {
        if isFree {
            return NSLocalizedString("free_or_warranty", comment: "Free/Warranty")
        }
        return cost.formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
    }
}

// Extension for MaintenanceType localization
extension MaintenanceType {
    var localizedString: String {
        switch self {
        case .oilChange:
            return NSLocalizedString("oil_change", comment: "Oil Change")
        case .brakes:
            return NSLocalizedString("brake_replacement", comment: "Brake Replacement")
        case .tires:
            return NSLocalizedString("tire_replacement", comment: "Tire Replacement")
        case .distributionBelt:
            return NSLocalizedString("distribution_belt", comment: "Distribution Belt")
        case .other:
            return NSLocalizedString("other_maintenance", comment: "Other")
        }
    }
}
