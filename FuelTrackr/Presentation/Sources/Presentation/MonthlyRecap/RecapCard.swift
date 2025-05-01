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

    public var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                RecapMetric(title: NSLocalizedString("km_driven", comment: ""), value: displayedDistance, icon: "car.fill", backgroundColor: .blue)
                RecapMetric(title: NSLocalizedString("total_fuel_used", comment: ""), value: displayedFuelUsed, icon: "fuelpump.fill", backgroundColor: .orange)
            }

            HStack(spacing: 12) {
                RecapMetric(title: NSLocalizedString("total_fuel_cost", comment: ""), value: displayedFuelCost, icon: "eurosign.circle.fill", backgroundColor: .green)
                RecapMetric(title: NSLocalizedString("average_fuel_usage", comment: ""), value: displayedAverage, icon: "speedometer", backgroundColor: .purple)
            }

            if let comparison = comparisonText {
                Text(comparison)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
