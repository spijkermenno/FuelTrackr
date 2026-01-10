// MARK: - Package: Presentation

//
//  MonthlySummaryCard.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain

public struct MonthlySummaryCard: View {
    public let monthTitle: String
    public let distance: String
    public let fuelUsed: String
    public let cost: String
    public let onDetailsTapped: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingL) {
            HStack {
                Label {
                    Text(monthTitle)
                        .font(Theme.typography.headlineFont)
                        .foregroundColor(colors.onBackground)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(colors.onBackground.opacity(0.7))
                }

                Spacer()

                Button(action: onDetailsTapped) {
                    Text(NSLocalizedString("details", comment: "Details"))
                        .font(Theme.typography.subheadlineFont)
                        .foregroundColor(colors.onPrimary)
                        .padding(.horizontal, Theme.dimensions.spacingM)
                        .padding(.vertical, Theme.dimensions.spacingS)
                        .background(colors.primary)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: Theme.dimensions.spacingM) {
                RecapMetric(
                    title: NSLocalizedString("km_driven", comment: "Distance"),
                    value: distance,
                    icon: "car.fill",
                    backgroundColor: colors.accentBlue
                )
                RecapMetric(
                    title: NSLocalizedString("total_fuel_used", comment: "Fuel used"),
                    value: fuelUsed,
                    icon: "fuelpump.fill",
                    backgroundColor: colors.accentOrange
                )
                RecapMetric(
                    title: NSLocalizedString("total_fuel_cost", comment: "Cost"),
                    value: cost,
                    icon: "eurosign.circle.fill",
                    backgroundColor: colors.accentGreen
                )
            }
        }
        .padding(Theme.dimensions.spacingXL)
        .background(colors.surface)
        .cornerRadius(12)
    }
}

public struct RecapMetric: View {
    public let title: String
    public let value: String
    public let icon: String
    public let backgroundColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }

    public var body: some View {
        VStack(spacing: Theme.dimensions.spacingS) {
            Circle()
                .fill(backgroundColor)
                .frame(width: Theme.dimensions.circleM, height: Theme.dimensions.circleM)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .semibold))
                )

            Text(value)
                .font(Theme.typography.headlineFont)
                .foregroundColor(colors.onBackground)

            Text(title)
                .font(Theme.typography.footnoteFont)
                .foregroundColor(colors.onSurface)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(Theme.dimensions.spacingL)
        .frame(maxWidth: .infinity, maxHeight: 160)
        .background(colors.background.opacity(0.5))
        .cornerRadius(12)
    }
}

//#Preview {
//    MonthlySummaryCard(
//        monthTitle: "April 2025",
//        distance: "500 km",
//        fuelUsed: "65.13 L",
//        cost: "€113,02"
//    ) {
//        print("Details tapped")
//    }
//    .padding()
//    .background(Theme.colors.background)
//    .previewLayout(.sizeThatFits)
//}
