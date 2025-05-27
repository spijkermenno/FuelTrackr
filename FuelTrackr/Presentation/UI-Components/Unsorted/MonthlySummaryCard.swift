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

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label {
                    Text(monthTitle)
                        .font(.headline)
                        .foregroundColor(Theme.colors.onBackground)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(Theme.colors.onBackground.opacity(0.7))
                }

                Spacer()

                Button(action: onDetailsTapped) {
                    Text(NSLocalizedString("details", comment: "Details"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.colors.onPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.colors.primary)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 12) {
                RecapMetric(
                    title: NSLocalizedString("km_driven", comment: "Distance"),
                    value: distance,
                    icon: "car.fill",
                    backgroundColor: .blue
                )
                RecapMetric(
                    title: NSLocalizedString("total_fuel_used", comment: "Fuel used"),
                    value: fuelUsed,
                    icon: "fuelpump.fill",
                    backgroundColor: .orange
                )
                RecapMetric(
                    title: NSLocalizedString("total_fuel_cost", comment: "Cost"),
                    value: cost,
                    icon: "eurosign.circle.fill",
                    backgroundColor: .green
                )
            }
        }
        .padding(20)
        .background(Theme.colors.surface)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

public struct RecapMetric: View {
    public let title: String
    public let value: String
    public let icon: String
    public let backgroundColor: Color

    public var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(backgroundColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 22, weight: .semibold))
                )

            Text(value)
                .font(.headline)
                .foregroundColor(Theme.colors.onBackground)

            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 160)
        .background(Color.gray.opacity(0.1))
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
