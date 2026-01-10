// MARK: - Package: Presentation

//
//  RecapCard.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 29/04/2025.
//

import SwiftUI
import Domain

public struct RecapCard: View {
    public let displayedDistance: String
    public let displayedFuelUsed: String
    public let displayedFuelCost: String
    public let displayedAverage: String
    public let comparisonText: String?

    public init(
        displayedDistance: String,
        displayedFuelUsed: String,
        displayedFuelCost: String,
        displayedAverage: String,
        comparisonText: String?
    ) {
        self.displayedDistance = displayedDistance
        self.displayedFuelUsed = displayedFuelUsed
        self.displayedFuelCost = displayedFuelCost
        self.displayedAverage = displayedAverage
        self.comparisonText = comparisonText
    }

    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(spacing: Theme.dimensions.spacingL) {
            HStack(spacing: Theme.dimensions.spacingM) {
                RecapMetric(
                    title: NSLocalizedString("km_driven", comment: ""),
                    value: displayedDistance,
                    icon: "car.fill",
                    backgroundColor: colors.accentBlue
                )
                RecapMetric(
                    title: NSLocalizedString("total_fuel_used", comment: ""),
                    value: displayedFuelUsed,
                    icon: "fuelpump.fill",
                    backgroundColor: colors.accentOrange
                )
            }

            HStack(spacing: Theme.dimensions.spacingM) {
                RecapMetric(
                    title: NSLocalizedString("total_fuel_cost", comment: ""),
                    value: displayedFuelCost,
                    icon: "eurosign.circle.fill",
                    backgroundColor: colors.accentGreen
                )
                RecapMetric(
                    title: NSLocalizedString("average_fuel_usage", comment: ""),
                    value: displayedAverage,
                    icon: "speedometer",
                    backgroundColor: colors.primary
                )
            }

            if let comparison = comparisonText {
                Text(comparison)
                    .font(Theme.typography.footnoteFont)
                    .foregroundColor(colors.onSurface)
                    .multilineTextAlignment(.center)
                    .padding(.top, Theme.dimensions.spacingS)
            }
        }
        .padding(Theme.dimensions.spacingL)
        .background(colors.surface)
        .cornerRadius(12)
    }
}
