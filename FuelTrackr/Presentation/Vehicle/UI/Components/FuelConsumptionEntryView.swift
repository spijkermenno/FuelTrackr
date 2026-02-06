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
    public let consumptionRate: Double // Consumption value (unit depends on fuel type)
    public let distanceDriven: Int // km
    public let fuelType: FuelType? // Vehicle fuel type
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
        fuelType: FuelType? = nil,
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
        self.fuelType = fuelType
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
            
            // All pills in a flow layout (wraps to multiple lines if needed, but tries to stay on one line)
            FlowLayout(spacing: 8, lineSpacing: 8) {
                SummaryPillView(
                    icon: "car.fill",
                    label: "",
                    value: formatFuel(entry.fuelVolume),
                    backgroundColor: colors.accentRedLight,
                    iconColor: colors.accentRed,
                    textColor: colorScheme == .dark ? colors.accentRed : hexColor("#613E8D") // Adaptive: red in dark mode, dark purple in light
                )
                
                SummaryPillView(
                    icon: "fuelpump.fill",
                    label: "",
                    value: formatPrice(entry.pricePerLiter),
                    backgroundColor: colors.accentGreenLight,
                    iconColor: colors.accentGreen,
                    textColor: colorScheme == .dark ? colors.accentGreen : hexColor("#306B42") // Adaptive: green in dark mode, dark green in light
                )
                
                SummaryPillView(
                    icon: "dollarsign.circle.fill",
                    label: "",
                    value: formatCost(entry.totalCost),
                    backgroundColor: colors.accentOrangeLight,
                    iconColor: colors.accentOrange,
                    textColor: colorScheme == .dark ? colors.accentOrange : hexColor("#8F6126") // Adaptive: orange in dark mode, dark orange in light
                )
                
                SummaryPillView(
                    icon: "fuelpump.fill",
                    label: "",
                    value: formatConsumption(entry.consumptionRate),
                    backgroundColor: colors.fuelUsagePillBackground,
                    iconColor: colors.fuelUsagePillText,
                    textColor: colors.fuelUsagePillText
                )
                
                SummaryPillView(
                    icon: "speedometer",
                    label: "",
                    value: formatDistance(entry.distanceDriven),
                    backgroundColor: colors.kmDrivenPillBackground,
                    iconColor: colors.kmDrivenPillText,
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
            return String(format: "%@ → %@ %@", start.formattedWithSeparator, end.formattedWithSeparator, NSLocalizedString("unit_km", comment: ""))
        } else {
            let startMi = Int(Double(start) * 0.621371)
            let endMi = Int(Double(end) * 0.621371)
            return String(format: "%@ → %@ %@", startMi.formattedWithSeparator, endMi.formattedWithSeparator, NSLocalizedString("unit_mi", comment: ""))
        }
    }
    
    private func formatFuel(_ amount: Double) -> String {
        let fuelType = entry.fuelType ?? .liquid
        return fuelType.formatFuelAmount(amount, isUsingMetric: settings.isUsingMetric)
    }
    
    private func formatPrice(_ pricePerUnit: Double) -> String {
        let fuelType = entry.fuelType ?? .liquid
        return fuelType.formatPricePerUnit(pricePerUnit, isUsingMetric: settings.isUsingMetric)
    }
    
    private func formatCost(_ cost: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "EUR"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0 // Allow no decimals if .00
        return formatter.string(from: NSNumber(value: cost)) ?? String(format: "%.2f", cost)
    }
    
    private func formatConsumption(_ consumption: Double) -> String {
        let fuelType = entry.fuelType ?? .liquid
        return fuelType.formatConsumption(consumption, isUsingMetric: settings.isUsingMetric)
    }
    
    private func formatDistance(_ km: Int) -> String {
        if settings.isUsingMetric {
            return String(format: "%d %@", km, NSLocalizedString("unit_km", comment: ""))
        } else {
            let miles = Int(Double(km) * 0.621371)
            return String(format: "%d %@", miles, NSLocalizedString("unit_mi", comment: ""))
        }
    }
}
