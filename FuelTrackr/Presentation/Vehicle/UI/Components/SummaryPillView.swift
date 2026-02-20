//
//  SummaryPillView.swift
//  FuelTrackr
//
//  Colored pill component for displaying fuel statistics
//

import SwiftUI

public struct SummaryPillView: View {
    let icon: String
    let label: String
    let value: String
    let backgroundColor: Color
    let iconColor: Color
    let textColor: Color
    
    public init(
        icon: String,
        label: String,
        value: String,
        backgroundColor: Color,
        iconColor: Color,
        textColor: Color? = nil
    ) {
        self.icon = icon
        self.label = label
        self.value = value
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.textColor = textColor ?? .primary
    }
    
    public var body: some View {
        if !label.isEmpty {
            // Full pill with label (for MonthlyFuelSummaryCard)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(iconColor)
                    Text(label)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.primary)
                }
                
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(backgroundColor)
            .cornerRadius(10)
        } else {
            // Compact pill without label (for FuelConsumptionEntryView)
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(iconColor)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .cornerRadius(8)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        SummaryPillView(
            icon: "location.fill",
            label: "Totale afstand",
            value: "500 km",
            backgroundColor: Color.blue.opacity(0.2),
            iconColor: .blue
        )
        SummaryPillView(
            icon: "fuelpump.fill",
            label: "Gemiddelde prijs",
            value: CurrencyFormatting.formatPricePerLiter(1.79),
            backgroundColor: Color.green.opacity(0.2),
            iconColor: .green
        )
    }
    .padding()
}
