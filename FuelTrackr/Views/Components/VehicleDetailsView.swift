//
//  VehicleDetailsView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/02/2025.
//

import SwiftUI

struct VehicleDetailsView: View {
    let vehicle: Vehicle
    let isMetric: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            detailRow(label: NSLocalizedString("license_plate_label", comment: ""), value: vehicle.licensePlate)
            detailRow(
                label: NSLocalizedString("mileage_label", comment: ""),
                value: "\(convertMileage(latestMileage, isMetric: isMetric)) \(isMetric ? "km" : "mi")"
            )
            detailRow(label: NSLocalizedString("purchase_date_label", comment: ""), value: vehicle.purchaseDate.formatted(date: .abbreviated, time: .omitted))
            detailRow(label: NSLocalizedString("manufacturing_date_label", comment: ""), value: vehicle.manufacturingDate.formatted(date: .abbreviated, time: .omitted))
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }

    private var latestMileage: Int {
        vehicle.mileages.last?.value ?? 0
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }

    private func convertMileage(_ mileage: Int, isMetric: Bool) -> Int {
        isMetric ? mileage : Int(Double(mileage) / 1.609)
    }
}
