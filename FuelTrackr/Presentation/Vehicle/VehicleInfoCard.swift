//
//  VehicleInfoCard.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//


//
//  VehicleInfoCard.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 22/04/2025.
//

import SwiftUI

struct VehicleInfoCard: View {
    @ObservedObject var viewModel: VehicleViewModel

    private var licensePlate: String {
        viewModel.activeVehicle?.licensePlate ?? "—"
    }

    private var mileage: Int {
        viewModel.activeVehicle?.mileages.max(by: { $0.date < $1.date })?.value ?? 0
    }

    private var purchaseDate: Date? {
        viewModel.activeVehicle?.purchaseDate
    }

    private var formattedMileage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)"
    }

    private var formattedPurchaseDate: String {
        guard let date = purchaseDate else { return "—" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }

    private var timeSincePurchase: String {
        guard let purchaseDate else { return "—" }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: purchaseDate, to: Date())

        var parts: [String] = []
        if let y = components.year, y > 0 { parts.append("\(y) \(NSLocalizedString("years", comment: ""))") }
        if let m = components.month, m > 0 { parts.append("\(m) \(NSLocalizedString("months", comment: ""))") }
        if let d = components.day, d > 0 { parts.append("\(d) \(NSLocalizedString("days", comment: ""))") }

        return parts.isEmpty ? NSLocalizedString("purchased_today", comment: "") : parts.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .resizable()
                    .frame(width: 28, height: 20)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(Circle())

                Text(licensePlate)
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    )

                Spacer()
            }
            .padding()

            VStack(alignment: .leading, spacing: 12) {
                VehicleInfoRow(label: NSLocalizedString("mileage_label", comment: ""), value: "\(formattedMileage) km")
                VehicleInfoRow(label: NSLocalizedString("purchase_date_label", comment: ""), value: formattedPurchaseDate)
                VehicleInfoRow(label: NSLocalizedString("since_purchase_label", comment: ""), value: timeSincePurchase)
            }
            .padding()
        }
        .frame(minHeight: 260)
        .background(Color(.systemBackground))
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 0)
    }
}

struct VehicleInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
        }
    }
}