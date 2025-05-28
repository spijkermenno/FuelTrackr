//
//  VehicleMetaCard.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//


//
//  VehicleMetaCard.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 25/04/2025.
//

import SwiftUI
import Domain


public struct VehicleMetaCard: View {
    let licenseplate: String
    let mileageText: String
    let purchaseDate: Date?
    let manufacturingDate: Date?

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Theme.colors.primary)
                        .frame(width: 42, height: 42)

                    Image(systemName: "car.fill")
                        .foregroundColor(Theme.colors.onPrimary)
                        .font(.system(size: 23, weight: .semibold))
                }

                Text(licenseplate)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.colors.onBackground)
            }

            VStack(alignment: .leading, spacing: 16) {
                VehicleMetaRow(
                    title: NSLocalizedString("mileage_title", comment: "Mileage"),
                    value: mileageText
                )
                VehicleMetaRow(
                    title: NSLocalizedString("purchase_date", comment: "Date of purchase"),
                    value: formattedDurationSince(date: purchaseDate)
                )
                VehicleMetaRow(
                    title: NSLocalizedString("manufacturing_date", comment: "Manufacturing date"),
                    value: formattedDurationSince(date: manufacturingDate)
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.colors.surface)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private func formattedDurationSince(date: Date?) -> String {
        guard let date else { return "—" }

        let components = Calendar.current.dateComponents([.year, .month, .day], from: date, to: Date())

        var parts: [String] = []
        if let years = components.year, years > 0 {
            parts.append("\(years) " + NSLocalizedString("years", comment: "years"))
        }
        if let months = components.month, months > 0 {
            parts.append("\(months) " + NSLocalizedString("months", comment: "months"))
        }
        if let days = components.day, days > 0 {
            parts.append("\(days) " + NSLocalizedString("days", comment: "days"))
        }

        return parts.isEmpty ? NSLocalizedString("today", comment: "Today") : parts.joined(separator: ", ")
    }
}

public struct VehicleMetaRow: View {
    let title: String
    let value: String

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Theme.colors.onSurface)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Theme.colors.secondary)
        }
    }
}
//
//#Preview {
//    VehicleMetaCard(
//        licenseplate: "TD-596-X",
//        mileageText: "80.481 km",
//        purchaseDate: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 31)),
//        manufacturingDate: Calendar.current.date(from: DateComponents(year: 2018, month: 1, day: 31))
//    )
//    .padding()
//    .background(Theme.colors.background)
//    .previewLayout(.sizeThatFits)
//}
