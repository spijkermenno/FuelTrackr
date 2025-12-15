// MARK: - Package: Presentation
//
//  FuelDetailsSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain
import Charts

public enum FuelDetailTimeframe: String, CaseIterable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"
    case yearToDate = "YTD"
    
    var localized: String {
        switch self {
        case .oneMonth:
            return NSLocalizedString("timeframe_1m", comment: "")
        case .threeMonths:
            return NSLocalizedString("timeframe_3m", comment: "")
        case .oneYear:
            return Locale.current.languageCode == "nl" ? NSLocalizedString("timeframe_1y", comment: "") : "1Y"
        case .yearToDate:
            return NSLocalizedString("timeframe_ytd", comment: "")
        }
    }
    
    func dateRange(from baseDate: Date = Date()) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let end = baseDate
        
        switch self {
        case .oneMonth:
            let start = calendar.date(byAdding: .month, value: -1, to: end) ?? end
            return (start, end)
        case .threeMonths:
            let start = calendar.date(byAdding: .month, value: -3, to: end) ?? end
            return (start, end)
        case .oneYear:
            let start = calendar.date(byAdding: .year, value: -1, to: end) ?? end
            return (start, end)
        case .yearToDate:
            let start = calendar.date(from: DateComponents(year: calendar.component(.year, from: end), month: 1, day: 1)) ?? end
            return (start, end)
        }
    }
}

public struct FuelDetailsSheet: View {
    public let viewModel: VehicleViewModel
    @Binding var showAddFuelSheet: Bool

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var resolvedVehicle: Vehicle?
    @State private var fuelToDelete: FuelUsage?
    @State private var showDeleteConfirmation = false
    @State private var selectedTimeframe: FuelDetailTimeframe = .threeMonths
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var filteredFuelUsages: [FuelUsage] {
        guard let vehicle = resolvedVehicle else { return [] }
        let range = selectedTimeframe.dateRange()
        return vehicle.fuelUsages
            .filter { $0.date >= range.start && $0.date <= range.end }
            .sorted(by: { $0.date > $1.date })
    }
    
    private var consumptionStats: (average: Double, totalCost: Double) {
        let usages = filteredFuelUsages.sorted(by: { $0.date < $1.date }) // Sort oldest to newest
        guard usages.count > 1 else { return (0, 0) }
        
        var totalDistance = 0
        var totalFuel = 0.0
        var totalCost = 0.0
        
        // Calculate distance and fuel for each segment
        // For each fill-up (except the last), the fuel added is used to drive to the next fill-up
        for i in 0..<usages.count - 1 {
            let usage = usages[i]
            let nextUsage = usages[i + 1]
            
            // Add fuel from this fill-up (used to drive to next fill-up)
            totalFuel += usage.liters
            totalCost += usage.cost
            
            // Calculate distance driven using this fuel (to next fill-up)
            if let currentMileage = usage.mileage?.value,
               let nextMileage = nextUsage.mileage?.value,
               nextMileage > currentMileage {
                totalDistance += nextMileage - currentMileage
            }
        }
        
        // Add cost from the last fill-up (even though we can't calculate its consumption yet)
        if let lastUsage = usages.last {
            totalCost += lastUsage.cost
        }
        
        // Calculate average: total distance / total fuel used (excluding last fill-up)
        let averageConsumption = totalFuel > 0 && totalDistance > 0 ? Double(totalDistance) / totalFuel : 0
        
        return (averageConsumption, totalCost)
    }
    
    private var monthsInTimeframe: Int {
        switch selectedTimeframe {
        case .oneMonth: return 1
        case .threeMonths: return 3
        case .oneYear: return 12
        case .yearToDate:
            return Calendar.current.component(.month, from: Date())
        }
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    if let vehicle = resolvedVehicle {
                        // Vehicle Info Header
                        VehicleInfoHeader(vehicle: vehicle)
                            .padding(.horizontal, Theme.dimensions.spacingL)
                            .padding(.top, Theme.dimensions.spacingM)
                        
                        // Timeframe Selector
                        TimeframeSelector(selectedTimeframe: $selectedTimeframe)
                            .padding(.horizontal, Theme.dimensions.spacingL)
                            .padding(.top, Theme.dimensions.spacingM)
                        
                        // Consumption Overview Card
                        ConsumptionOverviewCard(
                            averageConsumption: consumptionStats.average,
                            totalCost: consumptionStats.totalCost
                        )
                        .padding(.horizontal, Theme.dimensions.spacingL)
                        .padding(.top, Theme.dimensions.spacingM)
                        
                        // Graph
                        if filteredFuelUsages.count > 1 {
                            FuelConsumptionGraphView(
                                fuelUsages: filteredFuelUsages,
                                timeframe: selectedTimeframe,
                                isUsingMetric: viewModel.isUsingMetric
                            )
                            .padding(.horizontal, Theme.dimensions.spacingL)
                            .padding(.top, Theme.dimensions.spacingM)
                        }
                        
                        // Add Fuel Button
                        Button(action: { showAddFuelSheet = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text(NSLocalizedString("add_new_refueling", comment: ""))
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(colors.primary)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, Theme.dimensions.spacingL)
                        .padding(.top, Theme.dimensions.spacingM)
                        
                        // Fuel History List
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text(formatFuelEntriesTitle())
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(colors.onBackground)
                                Spacer()
                            }
                            .padding(.horizontal, Theme.dimensions.spacingL)
                            .padding(.top, Theme.dimensions.spacingL)
                            .padding(.bottom, Theme.dimensions.spacingM)
                            
                            if filteredFuelUsages.isEmpty {
                                Text(NSLocalizedString("fuel_usage_no_content", comment: ""))
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(colors.onSurface)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 24)
                            } else {
                                ForEach(Array(filteredFuelUsages.enumerated()), id: \.element.persistentModelID) { index, usage in
                                    DetailedFuelEntryRow(
                                        usage: usage,
                                        nextUsage: index < filteredFuelUsages.count - 1 ? filteredFuelUsages[index + 1] : nil
                                    )
                                    .padding(.horizontal, Theme.dimensions.spacingL)
                                    
                                    if index < filteredFuelUsages.count - 1 {
                                        Divider()
                                            .background(colors.divider)
                                            .padding(.horizontal, Theme.dimensions.spacingL)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, Theme.dimensions.spacingXL)
                    }
                }
            }
            .background(colors.background)
            .navigationTitle(NSLocalizedString("fuel_consumption", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(colors.onBackground)
                    }
                }
            }
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
            .onAppear {
                resolvedVehicle = viewModel.resolvedVehicle(context: context)
            }
        }
    }
    
    private func formatFuelEntriesTitle() -> String {
        let count = filteredFuelUsages.count
        if monthsInTimeframe == 1 {
            return String(format: NSLocalizedString("fuel_entries_last_month", comment: ""), count)
        } else {
            return String(format: NSLocalizedString("fuel_entries_last_months", comment: ""), monthsInTimeframe, count)
        }
    }
    
    private func deleteFuelUsage() {
        if let fuelUsage = fuelToDelete {
            viewModel.deleteFuelUsage(fuelUsage: fuelUsage, context: context)
            resolvedVehicle = viewModel.resolvedVehicle(context: context)
        }
        fuelToDelete = nil
        showDeleteConfirmation = false
    }
}

// MARK: - Vehicle Info Header

struct VehicleInfoHeader: View {
    let vehicle: Vehicle
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var latestMileage: Int {
        vehicle.latestMileage?.value ?? 0
    }
    
    private var lastRefuelingDate: Date? {
        vehicle.fuelUsages.sorted(by: { $0.date > $1.date }).first?.date
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(colors.primary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(vehicle.licensePlate.prefix(2)))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Text(vehicle.licensePlate)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colors.onBackground)
                
                Spacer()
            }
            
            HStack {
                Text(NSLocalizedString("mileage_label", comment: ""))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.onSurface)
                
                Spacer()
                
                Text("\(latestMileage.formattedWithSeparator) km")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(colors.onBackground)
            }
            
            if let lastDate = lastRefuelingDate {
                HStack {
                    Text(NSLocalizedString("last_refueling", comment: ""))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(colors.onSurface)
                    
                    Spacer()
                    
                    Text(formatDate(lastDate))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.onBackground)
                }
            }
        }
        .padding(Theme.dimensions.spacingL)
        .background(colors.surface)
        .cornerRadius(Theme.dimensions.radiusCard)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Timeframe Selector

struct TimeframeSelector: View {
    @Binding var selectedTimeframe: FuelDetailTimeframe
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FuelDetailTimeframe.allCases, id: \.self) { timeframe in
                Button(action: { selectedTimeframe = timeframe }) {
                    Text(timeframe.localized)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedTimeframe == timeframe ? .white : colors.onBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTimeframe == timeframe ? colors.primary : colors.surface)
                        .cornerRadius(8)
                }
            }
        }
    }
}

// MARK: - Consumption Overview Card

struct ConsumptionOverviewCard: View {
    let averageConsumption: Double
    let totalCost: Double
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("consumption_overview", comment: ""))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colors.onBackground)
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.2f", averageConsumption))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colors.primary)
                    
                    Text(NSLocalizedString("average_consumption", comment: ""))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(colors.onSurface)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(totalCost))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colors.onBackground)
                    
                    Text(NSLocalizedString("total_cost_label", comment: ""))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(colors.onSurface)
                }
            }
        }
        .padding(Theme.dimensions.spacingL)
        .background(colors.surface)
        .cornerRadius(Theme.dimensions.radiusCard)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "€%.2f", value)
    }
}

// MARK: - Fuel Consumption Graph View

struct FuelConsumptionGraphView: View {
    let fuelUsages: [FuelUsage]
    let timeframe: FuelDetailTimeframe
    let isUsingMetric: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var graphData: [(date: Date, consumption: Double, pricePerUnit: Double)] {
        // Sort oldest to newest for proper consumption calculation
        let sortedUsages = fuelUsages.sorted(by: { $0.date < $1.date })
        var data: [(date: Date, consumption: Double, pricePerUnit: Double)] = []
        
        for i in 0..<sortedUsages.count {
            let usage = sortedUsages[i]
            var consumption: Double = 0
            var pricePerUnit: Double = 0
            
            // Calculate consumption (compare with previous/older entry)
            if i > 0,
               let currentMileage = usage.mileage?.value,
               let previousMileage = sortedUsages[i - 1].mileage?.value,
               usage.liters > 0,
               currentMileage > previousMileage {
                let distance = Double(currentMileage - previousMileage)
                if isUsingMetric {
                    consumption = distance / usage.liters // km/l
                } else {
                    // Convert to miles per gallon
                    let miles = distance / 1.60934
                    let gallons = usage.liters * 0.264172
                    consumption = gallons > 0 ? miles / gallons : 0 // mpg
                }
            }
            
            // Calculate price per unit
            if usage.liters > 0 {
                if isUsingMetric {
                    pricePerUnit = usage.cost / usage.liters // €/L
                } else {
                    let gallons = usage.liters * 0.264172
                    pricePerUnit = gallons > 0 ? usage.cost / gallons : 0 // $/gal
                }
            }
            
            data.append((date: usage.date, consumption: consumption, pricePerUnit: pricePerUnit))
        }
        
        return data
    }
    
    private var consumptionUnit: String {
        isUsingMetric ? NSLocalizedString("km_per_liter", comment: "") : "mpg"
    }
    
    private var priceUnit: String {
        if isUsingMetric {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale.current
            let symbol = formatter.currencySymbol ?? "€"
            return "\(symbol)/L"
        } else {
            return NSLocalizedString("price_per_gallon", comment: "")
        }
    }
    
    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
    
    private var consumptionData: [(date: Date, value: Double)] {
        graphData.compactMap { dataPoint in
            dataPoint.consumption > 0 ? (dataPoint.date, dataPoint.consumption) : nil
        }
    }
    
    private var priceData: [(date: Date, value: Double)] {
        graphData.compactMap { dataPoint in
            dataPoint.pricePerUnit > 0 ? (dataPoint.date, dataPoint.pricePerUnit) : nil
        }
    }
    
    private var consumptionRange: (min: Double, max: Double) {
        let values = consumptionData.map { $0.value }
        guard let minValue = values.min(), let maxValue = values.max() else {
            return (0, 20)
        }
        let padding = (maxValue - minValue) * 0.1
        return (Swift.max(0, minValue - padding), maxValue + padding)
    }
    
    private var priceRange: (min: Double, max: Double) {
        let values = priceData.map { $0.value }
        guard let minValue = values.min(), let maxValue = values.max() else {
            return (0, 2)
        }
        let padding = (maxValue - minValue) * 0.1
        return (Swift.max(0, minValue - padding), maxValue + padding)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            consumptionChart
        }
        .padding(Theme.dimensions.spacingL)
        .background(colors.surface)
        .cornerRadius(Theme.dimensions.radiusCard)
    }
    
    @ViewBuilder
    private var consumptionChart: some View {
        let consumptionRangeValues = consumptionRange
        let hasConsumption = !consumptionData.isEmpty
        
        if hasConsumption {
            let yAxisMin = consumptionRangeValues.min
            let yAxisMax = consumptionRangeValues.max
            
            Chart {
                ForEach(consumptionData, id: \.date) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Consumption", dataPoint.value)
                    )
                    .foregroundStyle(colors.primary)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Consumption", dataPoint.value)
                    )
                    .foregroundStyle(colors.primary)
                    .symbolSize(30)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(formatGraphDate(date))
                                .font(.caption)
                                .foregroundColor(colors.onSurface)
                        }
                        AxisGridLine()
                            .foregroundStyle(colors.divider)
                    }
                }
            }
            .chartYScale(domain: yAxisMin...yAxisMax)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                    let doubleValue = value.as(Double.self) ?? 0.0
                    AxisValueLabel {
                        Text(String(format: "%.1f", doubleValue))
                            .font(.caption)
                            .foregroundColor(colors.onSurface)
                    }
                    AxisGridLine()
                        .foregroundStyle(colors.divider)
                }
            }
            .chartXAxisLabel(NSLocalizedString("date", comment: ""), position: .bottom, alignment: .center)
            .chartYAxisLabel(consumptionUnit, position: .leading, alignment: .center)
            .frame(height: 200)
        } else {
            Text(NSLocalizedString("fuel_usage_no_content", comment: ""))
                .font(.caption)
                .foregroundColor(colors.onSurface)
                .frame(height: 200)
        }
    }
    
    private func formatGraphDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Detailed Fuel Entry Row

struct DetailedFuelEntryRow: View {
    let usage: FuelUsage
    let nextUsage: FuelUsage?
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var startMileage: Int {
        nextUsage?.mileage?.value ?? (usage.mileage?.value ?? 0)
    }
    
    private var endMileage: Int {
        usage.mileage?.value ?? 0
    }
    
    private var consumption: Double? {
        guard let currentMileage = usage.mileage?.value,
              let previousMileage = nextUsage?.mileage?.value,
              usage.liters > 0,
              currentMileage > previousMileage else {
            return nil
        }
        let distance = Double(currentMileage - previousMileage)
        return distance / usage.liters
    }
    
    private var range: Double? {
        guard let consumption = consumption, usage.liters > 0 else { return nil }
        return consumption * usage.liters
    }
    
    private var pricePerLiter: Double {
        usage.liters > 0 ? usage.cost / usage.liters : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Date/Time and Mileage Range
            HStack {
                // Date and Time (blue, left)
                Text(formatDateTime(usage.date))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(colors.primary)
                
                Spacer()
                
                // Mileage Range (gray, right)
                Text("\(startMileage.formattedWithSeparator) -> \(endMileage.formattedWithSeparator) km")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.onSurface)
            }
            
            // First Row of Pills: Liters, Price/L, Total Cost
            HStack(spacing: 8) {
                // Liters (Purple pill with red car icon)
                FuelPill(
                    icon: "car.fill",
                    text: String(format: "%.2f", usage.liters).replacingOccurrences(of: ".", with: ",") + "L",
                    pillColor: .purple,
                    iconColor: .red
                )
                
                // Price per liter (Light green pill with red fuel pump icon)
                if usage.liters > 0 {
                    FuelPill(
                        icon: "fuelpump.fill",
                        text: formatPricePerLiter(pricePerLiter),
                        pillColor: Color(red: 0.7, green: 0.9, blue: 0.7), // Light green
                        iconColor: .red
                    )
                }
                
                // Total cost (Light orange pill with gold money bag icon)
                FuelPill(
                    icon: "dollarsign.circle.fill",
                    text: formatCurrency(usage.cost),
                    pillColor: Color(red: 1.0, green: 0.8, blue: 0.6), // Light orange
                    iconColor: Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
                )
                
                Spacer()
            }
            
            // Second Row of Pills: Consumption, Range
            HStack(spacing: 8) {
                // Consumption (Light blue pill with red location pin icon)
                if let consumption = consumption {
                    FuelPill(
                        icon: "location.fill",
                        text: String(format: "%.2f", consumption).replacingOccurrences(of: ".", with: ",") + " km/l",
                        pillColor: Color(red: 0.7, green: 0.85, blue: 1.0), // Light blue
                        iconColor: .red
                    )
                }
                
                // Range (Light blue pill with red location pin icon)
                if let range = range {
                    FuelPill(
                        icon: "location.fill",
                        text: String(format: "%.0f", range).replacingOccurrences(of: ".", with: ",") + " km",
                        pillColor: Color(red: 0.7, green: 0.85, blue: 1.0), // Light blue
                        iconColor: .red
                    )
                }
                
                Spacer()
            }
        }
        .padding(Theme.dimensions.spacingM)
        .background(colors.surface)
        .cornerRadius(12)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMM yyyy - HH:mm"
        return formatter.string(from: date).lowercased()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(format: "€%.2f", value)
        // Replace decimal separator to match design (comma instead of period)
        return formatted.replacingOccurrences(of: ".", with: ",")
    }
    
    private func formatPricePerLiter(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let formatted = formatter.string(from: NSNumber(value: value)) ?? String(format: "€%.2f", value)
        // Replace decimal separator and add /L
        return formatted.replacingOccurrences(of: ".", with: ",") + "/L"
    }
}

// MARK: - Fuel Pill

struct FuelPill: View {
    let icon: String
    let text: String
    let pillColor: Color
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(iconColor)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(pillColor.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(pillColor, lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

