//
//  VehicleDetailsView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain


public struct VehicleDetailsView: View {
    @State var vehicle: Vehicle
    let isMetric: Bool
    
    @State private var latestMileage: Int = 0

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            detailRow(label: NSLocalizedString("license_plate_label", comment: ""), value: vehicle.licensePlate)

            detailRow(
                label: NSLocalizedString("mileage_label", comment: ""),
                value: "\(formattedMileage(latestMileage)) \(isMetric ? "km" : "mi")"
            )

            detailRow(
                label: NSLocalizedString("purchase_date_label", comment: ""),
                value: vehicle.purchaseDate.formatted(date: .abbreviated, time: .omitted)
            )

            detailRow(
                label: NSLocalizedString("manufacturing_date_label", comment: ""),
                value: vehicle.manufacturingDate.formatted(date: .abbreviated, time: .omitted)
            )
        }
        .padding()
        .onAppear {
            latestMileage = vehicle.mileages.last?.value ?? 0
        }
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

    private func formattedMileage(_ mileage: Int) -> Int {
        isMetric ? mileage : Int(Double(mileage) / 1.60934)
    }
}
