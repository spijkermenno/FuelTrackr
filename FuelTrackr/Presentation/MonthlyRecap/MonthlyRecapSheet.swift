// MARK: - Package: Presentation

//
//  MonthlyRecapSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/04/2025.
//

import SwiftUI
import Domain
import SwiftData


public struct MonthlyRecapSheet: View {
    @Environment(\.modelContext) private var context

    @ObservedObject var viewModel: MonthlyRecapViewModel
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    @Environment(\.dismiss) private var dismiss

    public let showPreviousMonth: Bool

    public init(showPreviousMonth: Bool = false, viewmodel: MonthlyRecapViewModel) {
        self.showPreviousMonth = showPreviousMonth
        self.viewModel = viewmodel

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

    public var body: some View {
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
