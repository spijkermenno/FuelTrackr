//
//  AllFuelUsageView.swift
//  DriveWise
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

struct AllFuelUsageView: View {
    @ObservedObject var viewModel: VehicleViewModel

    var body: some View {
        NavigationView {
            List {
                if let fuelUsages = viewModel.activeVehicle?.fuelUsages {
                    ForEach(fuelUsages, id: \.self) { usage in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(usage.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Text("\(usage.liters, specifier: "%.2f") liters, €\(usage.cost, specifier: "%.2f")")
                                .font(.body)
                        }
                    }
                } else {
                    Text(NSLocalizedString("fuel_usage_no_content", comment: "Fuel usage information has no content"))
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .navigationTitle(NSLocalizedString("fuel_usage_list_title", comment: "Fuel usage list title"))
        }
    }
}
