//
//  MonthlyRecapSheet.swift
//  FuelTrackr
//

import SwiftUI
import SwiftData

struct MonthlyRecapSheet: View {
    @Environment(\.modelContext) private var context

    @StateObject private var viewModel: MonthlyRecapViewModel
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    @Environment(\.dismiss) private var dismiss

    let showPreviousMonth: Bool

    init(context: ModelContext, showPreviousMonth: Bool = false) {
        _viewModel = StateObject(wrappedValue: MonthlyRecapViewModelFactory.make(context: context))
        self.showPreviousMonth = showPreviousMonth

        let date: Date = {
            if showPreviousMonth {
                return Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            } else {
                return Date()
            }
        }()

        _selectedMonth = State(initialValue: Calendar.current.component(.month, from: date))
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: date))
    }

    // Computed recap values
    private var kmDriven: Int { viewModel.getKmDriven(month: selectedMonth, year: selectedYear) }
    private var totalFuelUsed: Double { viewModel.getFuelUsed(month: selectedMonth, year: selectedYear) }
    private var totalFuelCost: Double { viewModel.getFuelCost(month: selectedMonth, year: selectedYear) }
    private var averageFuelUsage: Double { viewModel.getAverageFuelUsage(month: selectedMonth, year: selectedYear) }
    private var isMetric: Bool { viewModel.isUsingMetric() }

    private var displayedDistance: String {
        if isMetric {
            return "\(kmDriven) km"
        } else {
            let miles = Double(kmDriven) / 1.60934
            return String(format: "%.0f mi", miles)
        }
    }

    private var displayedFuelUsed: String {
        if isMetric {
            return String(format: "%.2f L", totalFuelUsed)
        } else {
            let gallons = totalFuelUsed * 0.264172
            return String(format: "%.2f gal", gallons)
        }
    }

    private var displayedAverage: String {
        if isMetric {
            return String(format: "%.2f km/L", averageFuelUsage)
        } else {
            let mpg = averageFuelUsage * 2.35215
            return String(format: "%.2f mi/gal", mpg)
        }
    }

    private var comparisonText: String? {
        var previousMonth = selectedMonth
        var previousYear = selectedYear

        if selectedMonth > 1 {
            previousMonth -= 1
        } else {
            previousMonth = 12
            previousYear -= 1
        }

        let currentKm = kmDriven
        let previousKm = viewModel.getKmDriven(month: previousMonth, year: previousYear)

        guard previousKm > 0, currentKm > 0 else { return nil }

        let change = (Double(currentKm - previousKm) / Double(previousKm)) * 100
        return String(format: NSLocalizedString("comparison_result", comment: ""), change)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                MonthNavigationHeader(selectedMonth: $selectedMonth, selectedYear: $selectedYear)

                if kmDriven == 0 && totalFuelUsed == 0 && totalFuelCost == 0 {
                    EmptyStateView()
                } else {
                    RecapCard(
                        displayedDistance: displayedDistance,
                        displayedFuelUsed: displayedFuelUsed,
                        displayedFuelCost: String(format: "€%.2f", totalFuelCost),
                        displayedAverage: displayedAverage,
                        comparisonText: comparisonText
                    )
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Empty State View

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)

            Text(NSLocalizedString("no_data_available", comment: ""))
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Month Navigation Header

private struct MonthNavigationHeader: View {
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int

    private var isNextMonthInFuture: Bool {
        var nextMonth = selectedMonth
        var nextYear = selectedYear

        if selectedMonth < 12 {
            nextMonth += 1
        } else {
            nextMonth = 1
            nextYear += 1
        }

        let now = Date()
        let currentComponents = Calendar.current.dateComponents([.year, .month], from: now)

        if let currentYear = currentComponents.year, let currentMonth = currentComponents.month {
            return nextYear > currentYear || (nextYear == currentYear && nextMonth > currentMonth)
        }

        return false
    }

    var body: some View {
        HStack(spacing: 8) {
            Spacer()

            Button(action: {
                if selectedMonth > 1 {
                    selectedMonth -= 1
                } else {
                    selectedMonth = 12
                    selectedYear -= 1
                }
            }) {
                Image(systemName: "chevron.left")
            }

            Spacer()

            if let monthDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                Text(monthDate, format: Date.FormatStyle().month(.wide).year())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Spacer()

            Button(action: {
                if selectedMonth < 12 {
                    selectedMonth += 1
                } else {
                    selectedMonth = 1
                    selectedYear += 1
                }
            }) {
                Image(systemName: "chevron.right")
            }
            .disabled(isNextMonthInFuture)

            Spacer()
        }
        .padding(.top, 30)
        .padding(.horizontal, 32)
    }
}

// MARK: - Recap Card

private struct RecapCard: View {
    let displayedDistance: String
    let displayedFuelUsed: String
    let displayedFuelCost: String
    let displayedAverage: String
    let comparisonText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            RecapRow(title: NSLocalizedString("km_driven", comment: ""), value: displayedDistance)
            RecapRow(title: NSLocalizedString("total_fuel_used", comment: ""), value: displayedFuelUsed)
            RecapRow(title: NSLocalizedString("total_fuel_cost", comment: ""), value: displayedFuelCost)
            RecapRow(title: NSLocalizedString("average_fuel_usage", comment: ""), value: displayedAverage)

            if let comparison = comparisonText {
                RecapRow(title: NSLocalizedString("comparison", comment: ""), value: comparison)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

// MARK: - Recap Row

private struct RecapRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundColor(.orange)
        }
    }
}
