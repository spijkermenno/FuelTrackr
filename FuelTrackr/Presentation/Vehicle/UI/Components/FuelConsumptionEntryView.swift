//
//  FuelConsumptionEntryView.swift
//  FuelTrackr
//
//  Single fuel consumption entry row with colored pills
//

import SwiftUI
import SwiftData
import Domain

public struct FuelConsumptionEntryUiModel: Identifiable {
    public let id: UUID
    public let fuelUsageID: PersistentIdentifier
    public let date: Date
    public let startOdometer: Int
    public let endOdometer: Int
    public let fuelVolume: Double
    public let pricePerLiter: Double
    public let totalCost: Double
    public let consumptionRate: Double // km/l
    public let distanceDriven: Int // km
    public let containsPartialFills: Bool // True if this merged entry contains partial fills
    
    public init(
        id: UUID = UUID(),
        fuelUsageID: PersistentIdentifier,
        date: Date,
        startOdometer: Int,
        endOdometer: Int,
        fuelVolume: Double,
        pricePerLiter: Double,
        totalCost: Double,
        consumptionRate: Double,
        distanceDriven: Int,
        containsPartialFills: Bool = false
    ) {
        self.id = id
        self.fuelUsageID = fuelUsageID
        self.date = date
        self.startOdometer = startOdometer
        self.endOdometer = endOdometer
        self.fuelVolume = fuelVolume
        self.pricePerLiter = pricePerLiter
        self.totalCost = totalCost
        self.consumptionRate = consumptionRate
        self.distanceDriven = distanceDriven
        self.containsPartialFills = containsPartialFills
    }
}

public struct FuelConsumptionEntryView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: SettingsViewModel
    let entry: FuelConsumptionEntryUiModel
    let onEdit: () -> Void
    let onPartialFillTapped: (() -> Void)?
    
    init(entry: FuelConsumptionEntryUiModel, onEdit: @escaping () -> Void, onPartialFillTapped: (() -> Void)? = nil) {
        self.entry = entry
        self.onEdit = onEdit
        self.onPartialFillTapped = onPartialFillTapped
    }
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Date
            HStack {
                Text(formatDate(entry.date))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.primary)
                
                Spacer()
            }
            
            // Odometer range
            Text(formatOdometerRange(entry.startOdometer, entry.endOdometer))
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(colors.onSurface)
            
            // Pills row 1 - 3 pills with colored backgrounds and dark text
            HStack(spacing: 8) {
                SummaryPillView(
                    icon: "car.fill",
                    label: "",
                    value: formatFuel(entry.fuelVolume),
                    backgroundColor: colors.accentRedLight,
                    iconColor: hexColor("#E63946"), // Red icon
                    textColor: hexColor("#613E8D") // Dark purple for text
                )
                
                SummaryPillView(
                    icon: "fuelpump.fill",
                    label: "",
                    value: formatPrice(entry.pricePerLiter),
                    backgroundColor: colors.accentGreenLight,
                    iconColor: hexColor("#00C864"), // Green icon
                    textColor: hexColor("#306B42") // Dark green for text
                )
                
                SummaryPillView(
                    icon: "dollarsign.circle.fill",
                    label: "",
                    value: formatCost(entry.totalCost),
                    backgroundColor: colors.accentOrangeLight,
                    iconColor: hexColor("#FFB400"), // Orange icon
                    textColor: hexColor("#8F6126") // Dark orange for text
                )
            }
            
            // Pills row 2 - fuel usage and km driven pills with specific colors
            HStack(spacing: 8) {
                SummaryPillView(
                    icon: "fuelpump.fill",
                    label: "",
                    value: formatConsumption(entry.consumptionRate),
                    backgroundColor: colors.fuelUsagePillBackground,
                    iconColor: colors.accentRed,
                    textColor: colors.fuelUsagePillText
                )
                
                SummaryPillView(
                    icon: "speedometer",
                    label: "",
                    value: formatDistance(entry.distanceDriven),
                    backgroundColor: colors.kmDrivenPillBackground,
                    iconColor: colors.accentRed,
                    textColor: colors.kmDrivenPillText
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM yyyy" // e.g., "14 december 2025"
        let formatted = formatter.string(from: date)
        // Make month name lowercase to match design
        let components = formatted.components(separatedBy: " ")
        if components.count >= 3 {
            let day = components[0]
            let month = components[1].lowercased()
            let year = components[2]
            return "\(day) \(month) \(year)"
        }
        return formatted
    }
    
    private func formatOdometerRange(_ start: Int, _ end: Int) -> String {
        if settings.isUsingMetric {
            return String(format: "%@ → %@ km", start.formattedWithSeparator, end.formattedWithSeparator)
        } else {
            let startMi = Int(Double(start) * 0.621371)
            let endMi = Int(Double(end) * 0.621371)
            return String(format: "%@ → %@ mi", startMi.formattedWithSeparator, endMi.formattedWithSeparator)
        }
    }
    
    private func formatFuel(_ liters: Double) -> String {
        if settings.isUsingMetric {
            return String(format: "%.2fL", liters)
        } else {
            let gallons = liters * 0.264172
            return String(format: "%.2fG", gallons)
        }
    }
    
    private func formatPrice(_ pricePerLiter: Double) -> String {
        if settings.isUsingMetric {
            return String(format: "€%.2f/L", pricePerLiter)
        } else {
            let pricePerGallon = pricePerLiter * 3.78541
            return String(format: "$%.2f/G", pricePerGallon)
        }
    }
    
    private func formatCost(_ cost: Double) -> String {
        return cost.formatted(.currency(code: Locale.current.currency?.identifier ?? "EUR"))
    }
    
    private func formatConsumption(_ kmPerLiter: Double) -> String {
        if settings.isUsingMetric {
            return String(format: "%.2f km/l", kmPerLiter)
        } else {
            let mpg = kmPerLiter * 2.35215
            return String(format: "%.2f mpg", mpg)
        }
    }
    
    private func formatDistance(_ km: Int) -> String {
        if settings.isUsingMetric {
            return String(format: "%d km", km)
        } else {
            let miles = Int(Double(km) * 0.621371)
            return String(format: "%d mi", miles)
        }
    }
}
