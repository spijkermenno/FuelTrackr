//
//  MonthlyFuelSummaryCard.swift
//  FuelTrackr
//
//  Card displaying monthly fuel summary with 4 colored pills
//

import SwiftUI
import Domain

public struct MonthlyFuelSummaryCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let summary: MonthlyFuelSummaryUiModel
    let isUsingMetric: Bool
    let fuelType: FuelType?
    
    public init(summary: MonthlyFuelSummaryUiModel, isUsingMetric: Bool, fuelType: FuelType? = nil) {
        self.summary = summary
        self.isUsingMetric = isUsingMetric
        self.fuelType = fuelType
    }
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colors.primary)
                Text(summary.monthYearString)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colors.onBackground)
            }
            
            // 2x2 Grid of pills
            VStack(spacing: 12) {
                // Top row
                HStack(spacing: 12) {
                    SummaryPillView(
                        icon: "location.fill",
                        label: isUsingMetric ? NSLocalizedString("total_distance_km", comment: "Total distance") : NSLocalizedString("total_distance_miles", comment: "Total distance"),
                        value: formatDistance(summary.totalDistance),
                        backgroundColor: colors.accentBlueLight,
                        iconColor: colors.accentBlue
                    )
                    
                    SummaryPillView(
                        icon: "fuelpump.fill",
                        label: NSLocalizedString("average_price", comment: "Average price"),
                        value: formatPrice(summary.averagePricePerLiter),
                        backgroundColor: colors.accentGreenLight,
                        iconColor: colors.accentGreen
                    )
                }
                
                // Bottom row
                HStack(spacing: 12) {
                    SummaryPillView(
                        icon: "fuelpump.fill",
                        label: NSLocalizedString("fuel", comment: "Fuel"),
                        value: formatFuel(summary.totalFuelVolume),
                        backgroundColor: colors.accentRedLight,
                        iconColor: colors.accentRed
                    )
                    
                    SummaryPillView(
                        icon: "dollarsign.circle.fill",
                        label: NSLocalizedString("costs", comment: "Costs"),
                        value: formatCost(summary.totalCost),
                        backgroundColor: colors.accentOrangeLight,
                        iconColor: colors.accentOrange
                    )
                }
            }
        }
        .padding()
        .background(colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 31))
        .overlay(
            RoundedRectangle(cornerRadius: 31)
                .stroke(colors.border, lineWidth: 1)
        )
    }
    
    private func formatDistance(_ km: Double) -> String {
        print("KM: \(km)")
        if isUsingMetric {
            return String(format: "%.0f %@", km, NSLocalizedString("unit_km", comment: ""))
        } else {
            let miles = km * 0.621371
            return String(format: "%.0f %@", miles, NSLocalizedString("unit_mi", comment: ""))
        }
    }
    
    private func formatPrice(_ pricePerUnit: Double) -> String {
        let fuelTypeToUse = fuelType ?? .liquid
        return fuelTypeToUse.formatPricePerUnit(pricePerUnit, isUsingMetric: isUsingMetric, currency: GetSelectedCurrencyUseCase()())
    }
    
    private func formatFuel(_ amount: Double) -> String {
        let fuelTypeToUse = fuelType ?? .liquid
        return fuelTypeToUse.formatFuelAmount(amount, isUsingMetric: isUsingMetric)
    }
    
    private func formatCost(_ cost: Double) -> String {
        CurrencyFormatting.format(cost)
    }
}
