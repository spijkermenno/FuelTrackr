//
//  CurrentMonthRecapView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI

struct CurrentMonthRecapView: View {
    @ObservedObject var viewModel: VehicleViewModel

    private var selectedMonth: Int
    private var selectedYear: Int

    init(viewModel: VehicleViewModel) {
        self.viewModel = viewModel
        let now = Date()
        selectedMonth = Calendar.current.component(.month, from: now)
        selectedYear = Calendar.current.component(.year, from: now)
    }

    private var kmDriven: Int { viewModel.kmDriven(forMonth: selectedMonth, year: selectedYear) }
    private var totalFuelUsed: Double { viewModel.fuelUsed(forMonth: selectedMonth, year: selectedYear) }
    private var totalFuelCost: Double { viewModel.fuelCost(forMonth: selectedMonth, year: selectedYear) }
    private var averageFuelUsage: Double { viewModel.averageFuelUsage(forMonth: selectedMonth, year: selectedYear) }

    private var isMetric: Bool { SettingsRepository().isUsingMetric() }

    private var displayedDistance: String {
        isMetric ? "\(kmDriven) km" : String(format: "%.0f mi", Double(kmDriven) / 1.60934)
    }

    private var displayedFuelUsed: String {
        isMetric ? String(format: "%.2f L", totalFuelUsed) : String(format: "%.2f gal", totalFuelUsed * 0.264172)
    }

    private var displayedAverage: String {
        isMetric ? String(format: "%.2f km/L", averageFuelUsage) : String(format: "%.2f mi/gal", averageFuelUsage * 2.35215)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(DateFormatter().monthSymbols[selectedMonth - 1]) Recap")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 16) {
                RecapRow(title: NSLocalizedString("km_driven", comment: ""), value: displayedDistance)
                RecapRow(title: NSLocalizedString("total_fuel_used", comment: ""), value: displayedFuelUsed)
                RecapRow(title: NSLocalizedString("total_fuel_cost", comment: ""), value: String(format: "€%.2f", totalFuelCost))
                RecapRow(title: NSLocalizedString("average_fuel_usage", comment: ""), value: displayedAverage)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 260)
        .padding()
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(15)
    }
}
