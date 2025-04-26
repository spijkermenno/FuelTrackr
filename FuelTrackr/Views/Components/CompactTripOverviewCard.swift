//
//  CompactTripOverviewCard.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 22/04/2025.
//

import SwiftUI

struct CompactTripOverviewCard: View {
    @ObservedObject var viewModel: VehicleViewModel

    private var selectedMonth: Int
    private var selectedYear: Int
    private let isMetric: Bool

    init(viewModel: VehicleViewModel) {
        self.viewModel = viewModel
        let now = Date()
        self.selectedMonth = Calendar.current.component(.month, from: now)
        self.selectedYear = Calendar.current.component(.year, from: now)
        self.isMetric = SettingsRepository().isUsingMetric()
    }

    private var kmDriven: Int {
        viewModel.kmDriven(forMonth: selectedMonth, year: selectedYear)
    }

    private var fuelUsed: Double {
        viewModel.fuelUsed(forMonth: selectedMonth, year: selectedYear)
    }

    private var fuelCost: Double {
        viewModel.fuelCost(forMonth: selectedMonth, year: selectedYear)
    }

    private var avgFuelUsage: Double {
        viewModel.averageFuelUsage(forMonth: selectedMonth, year: selectedYear)
    }

    private var displayedDistance: String {
        isMetric ? "\(kmDriven.formattedWithSeparator) km" :
            String(format: "%.0f mi", Double(kmDriven) / 1.60934)
    }

    private var displayedFuelUsed: String {
        isMetric ? String(format: "%.2f L", fuelUsed) :
            String(format: "%.2f gal", fuelUsed * 0.264172)
    }

    private var displayedFuelCost: String {
        String(format: "€%.2f", fuelCost)
    }

    private var displayedAverage: String {
        isMetric ? String(format: "%.2f km/L", avgFuelUsage) :
            String(format: "%.2f mi/gal", avgFuelUsage * 2.35215)
    }

    private var formattedMonthString: String {
        let calendar = Calendar.current
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        let date = calendar.date(from: components) ?? Date()

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL yyyy"

        let formatted = formatter.string(from: date)
        return formatted.prefix(1).capitalized + formatted.dropFirst()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text(formattedMonthString)
                    .font(.headline)
            }
            .padding(.top, 12)
            .padding(.horizontal)

            HStack(spacing: 6) {
                StatBlock(color: .blue, icon: "car.fill", value: displayedDistance, unit: NSLocalizedString("km_driven", comment: ""))
                StatBlock(color: .orange, icon: "fuelpump.fill", value: displayedFuelUsed, unit: NSLocalizedString("total_fuel_used", comment: ""))
                StatBlock(color: .green, icon: "eurosign.circle.fill", value: displayedFuelCost, unit: NSLocalizedString("total_fuel_cost", comment: ""))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(minHeight: 260)
        .background(Color(.systemBackground))
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 0)
    }
}

struct StatBlock: View {
    let color: Color
    let icon: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .padding(10)
                .background(color)
                .clipShape(Circle())

            Text(value)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension VehicleViewModel {
    static var mock: VehicleViewModel {
        let vm = VehicleViewModel()
        // Inject mock data here if needed
        return vm
    }
}
