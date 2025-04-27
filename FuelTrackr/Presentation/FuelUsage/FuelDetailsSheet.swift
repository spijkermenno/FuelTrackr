//
//  FuelDetailsSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//


//
//  FuelDetailsSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI
import Charts

struct FuelDetailsSheet: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var fuelToDelete: FuelUsage?
    @State private var showDeleteConfirmation = false
    
    private var sortedFuelUsages: [FuelUsage] {
        guard let fuelUsages = viewModel.activeVehicle?.fuelUsages else { return [] }
        return fuelUsages.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {
        NavigationView {
            List {
                if !sortedFuelUsages.isEmpty {
                    Section {
                        if sortedFuelUsages.count > 1 {
                            FuelUsageGraphView(fuelHistory: sortedFuelUsages)
                                .padding(.vertical)
                        }
                        
                        ForEach(Array(sortedFuelUsages.enumerated()), id: \.element) { index, usage in
                            FuelUsageListRow(usage: usage, nextUsage: index < sortedFuelUsages.count - 1 ? sortedFuelUsages[index + 1] : nil)
                                .padding(.vertical, 4)
                        }
                        .onDelete(perform: confirmDelete)
                    }
                } else {
                    Text(NSLocalizedString("fuel_usage_no_content", comment: ""))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .navigationTitle(NSLocalizedString("fuel_usage_list_title", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text(NSLocalizedString("close", comment: ""))
                            .bold()
                            .foregroundColor(.orange)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .confirmationDialog(
                NSLocalizedString("delete_confirmation_title", comment: ""),
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(NSLocalizedString("delete_confirmation_delete", comment: ""), role: .destructive) {
                    deleteFuelUsage()
                }
                Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                    fuelToDelete = nil
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
    
    private func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            fuelToDelete = sortedFuelUsages[index]
            showDeleteConfirmation = true
        }
    }
    
    private func deleteFuelUsage() {
        if let fuelUsage = fuelToDelete {
            viewModel.deleteFuelUsage(fuelUsage: fuelUsage)
        }
        fuelToDelete = nil
        showDeleteConfirmation = false
    }
}

// MARK: - Fuel Usage Row

struct FuelUsageListRow: View {
    let usage: FuelUsage
    let nextUsage: FuelUsage?

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(usage.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(usage.liters, specifier: "%.2f") liters")
                    .font(.headline)

                Text("€\(usage.cost, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                if usage.liters > 0 {
                    FuelBadge(text: String(format: "%.3f€/L", usage.cost / usage.liters))
                }
                
                if let currentMileage = usage.mileage?.value,
                   let previousMileage = nextUsage?.mileage?.value,
                   currentMileage > previousMileage,
                   usage.liters > 0 {
                    let distance = Double(currentMileage - previousMileage)
                    let kmPerLiter = distance / usage.liters
                    FuelBadge(text: String(format: "%.2f km/l", kmPerLiter))

                    let pricePerKm = usage.cost / distance
                    FuelBadge(text: String(format: "%.3f€/km", pricePerKm))
                }
            }
        }
    }
}

private struct FuelBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.orange)
            .padding(8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
    }
}

// MARK: - FuelUsage extension

extension FuelUsage {
    var formattedDate: String {
        let style = Date.FormatStyle()
            .day()
            .month(.wide)
            .year()
            .locale(Locale.current)
        return self.date.formatted(style)
    }
}

// MARK: - Graph View

struct FuelUsageGraphView: View {
    let fuelHistory: [FuelUsage]

    var body: some View {
        let dailyKmPerLiterData = preprocessDailyKmPerLiter(fuelHistory: fuelHistory)

        Chart {
            ForEach(dailyKmPerLiterData, id: \.0) { (date, kmPerLiter) in
                LineMark(
                    x: .value(NSLocalizedString("date", comment: ""), date),
                    y: .value("kmPerLiter", kmPerLiter)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.orange.gradient)
                
                PointMark(
                    x: .value(NSLocalizedString("date", comment: ""), date),
                    y: .value("kmPerLiter", kmPerLiter)
                )
                .foregroundStyle(Color.orange)
                .symbolSize(20)

                AreaMark(
                    x: .value(NSLocalizedString("date", comment: ""), date),
                    yStart: .value("kmPerLiter", 0),
                    yEnd: .value("kmPerLiter", kmPerLiter)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date, format: .dateTime.day().month(.abbreviated))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    Text("\(value.as(Double.self) ?? 0, specifier: "%.1f") km/l")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartYAxisLabel("km/l", position: .leading)
        .chartXAxisLabel(NSLocalizedString("date", comment: ""), position: .bottom)
        .chartLegend(.hidden)
        .frame(maxWidth: .infinity, minHeight: 250)
        .padding(.vertical)
    }

    private func preprocessDailyKmPerLiter(fuelHistory: [FuelUsage]) -> [(key: Date, value: Double)] {
        let dailyEntries = Dictionary(grouping: fuelHistory, by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.max(by: { $0.liters < $1.liters })! }
            .sorted(by: { $0.key < $1.key })

        var kmData: [(Date, Double)] = []

        for i in 1..<dailyEntries.count {
            let current = dailyEntries[i].value
            let previous = dailyEntries[i - 1].value

            if let currentMileage = current.mileage?.value,
               let previousMileage = previous.mileage?.value,
               current.liters > 0 {
                let kmPerLiter = Double(currentMileage - previousMileage) / current.liters
                kmData.append((dailyEntries[i].key, kmPerLiter))
            }
        }
        return kmData
    }
}