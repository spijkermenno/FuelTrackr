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
    @Environment(\.modelContext) private var context
    
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
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(usage.formattedDate)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("\(usage.liters, specifier: "%.2f") liters")
                                        .font(.headline)
                                    
                                    Text("€\(usage.cost, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    // Price per liter
                                    if usage.liters > 0 {
                                        let pricePerLiter = usage.cost / usage.liters
                                        let formattedPricePerLiter = String(format: "%.3f€/L", locale: Locale(identifier: "de_DE"), pricePerLiter)
                                        Text(formattedPricePerLiter)
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                            .padding(8)
                                            .background(Color.orange.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    
                                    // km per liter (if available)
                                    if index < sortedFuelUsages.count - 1,
                                       let currentMileage = usage.mileage?.value,
                                       let previousMileage = sortedFuelUsages[index + 1].mileage?.value,
                                       currentMileage > previousMileage,
                                       usage.liters > 0 {
                                        let distance = Double(currentMileage - previousMileage)
                                        if distance > 0 {
                                            let kmPerLiter = distance / usage.liters
                                            let formattedKmPerLiter = String(format: "%.2f km/l", locale: Locale(identifier: "de_DE"), kmPerLiter)
                                            Text(formattedKmPerLiter)
                                                .font(.caption)
                                                .foregroundStyle(.orange)
                                                .padding(8)
                                                .background(Color.orange.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                    
                                    // Price per km (if available)
                                    if index < sortedFuelUsages.count - 1,
                                       let currentMileage = usage.mileage?.value,
                                       let previousMileage = sortedFuelUsages[index + 1].mileage?.value,
                                       currentMileage > previousMileage {
                                        let distance = Double(currentMileage - previousMileage)
                                        if distance > 0 {
                                            let pricePerKm = usage.cost / distance
                                            let formattedPricePerKm = String(format: "%.3f€/km", locale: Locale(identifier: "de_DE"), pricePerKm)
                                            Text(formattedPricePerKm)
                                                .font(.caption)
                                                .foregroundStyle(.orange)
                                                .padding(8)
                                                .background(Color.orange.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
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
                            .foregroundStyle(Color.orange)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
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
                    showDeleteConfirmation = false
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
        if let fuelToDelete = fuelToDelete {
            viewModel.deleteFuelUsage(context: context, fuelUsage: fuelToDelete)
        }
        // Reset deletion state
        self.fuelToDelete = nil
        showDeleteConfirmation = false
    }
}

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

struct FuelUsageGraphView: View {
    let fuelHistory: [FuelUsage]
    
    var body: some View {
        // Preprocess the fuel history to produce an array of (Date, kmPerLiter)
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
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                if let dateValue = value.as(Date.self) {
                    AxisValueLabel {
                        Text(dateValue, format: .dateTime.day().month(.abbreviated))
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
    
    /// Preprocesses the fuel history to compute a daily km per liter value.
    /// It groups fuelings by day (using the start of the day) and selects the fueling with the maximum liters for each day.
    /// Then, for each day (starting from the second day), it computes km/l by comparing the current and previous day's mileage.
    private func preprocessDailyKmPerLiter(fuelHistory: [FuelUsage]) -> [(key: Date, value: Double)] {
        let dailyEntries = Dictionary(grouping: fuelHistory, by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.max(by: { $0.liters < $1.liters })! }
            .sorted(by: { $0.key < $1.key })
        
        var kmData: [(Date, Double)] = []
        // We need at least two days of data to compute km/l.
        for i in 1..<dailyEntries.count {
            let currentFuelUsage = dailyEntries[i].value
            let previousFuelUsage = dailyEntries[i - 1].value
            if let currentMileage = currentFuelUsage.mileage?.value,
               let previousMileage = previousFuelUsage.mileage?.value,
               currentFuelUsage.liters > 0 {
                let kmPerLiter = Double(currentMileage - previousMileage) / currentFuelUsage.liters
                kmData.append((dailyEntries[i].key, kmPerLiter))
            }
        }
        return kmData
    }
}
