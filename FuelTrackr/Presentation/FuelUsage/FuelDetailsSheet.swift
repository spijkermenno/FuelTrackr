// MARK: - Package: Presentation
//
//  FuelDetailsSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import FirebaseAnalytics
import Domain
import Charts
import SwiftData
import ScovilleKit

public enum FuelDetailTimeframe: String, CaseIterable {
    case all = "All"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"
    case yearToDate = "YTD"
    
    var localized: String {
        switch self {
        case .all:
            return NSLocalizedString("timeframe_all", comment: "")
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
        case .all:
            // Return a very early date to include all data
            return (Date.distantPast, end)
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
    @State private var fuelUsageForPartialFillManagement: FuelUsageSelection?
    @State private var fuelUsageForEditing: FuelUsageSelection?
    
    private struct FuelUsageSelection: Identifiable {
        let id: PersistentIdentifier
        let fuelUsage: FuelUsage
    }
    
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
    
    private var graphDataUsages: [FuelUsage] {
        guard let vehicle = resolvedVehicle else { return [] }
        let range = selectedTimeframe.dateRange()
        let allUsages = vehicle.fuelUsages
            .filter { $0.date >= range.start && $0.date <= range.end }
        
        // Get merged groups
        let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
        
        // Collect closing entries from groups and standalone full fills
        var graphUsages: [FuelUsage] = []
        var processedIDs = Set<PersistentIdentifier>()
        
        // Add closing entries from merged groups
        for group in groups {
            if group.count > 1 {
                // Find the closing entry (first non-partial fill when sorted by date)
                let sortedByDate = group.sorted { $0.date < $1.date }
                if let closingEntry = sortedByDate.first(where: { !$0.isPartialFill }),
                   allUsages.contains(where: { $0.persistentModelID == closingEntry.persistentModelID }) {
                    graphUsages.append(closingEntry)
                    group.forEach { processedIDs.insert($0.persistentModelID) }
                }
            }
        }
        
        // Add standalone full fills (not part of any group)
        for usage in allUsages {
            if !processedIDs.contains(usage.persistentModelID) && !usage.isPartialFill {
                graphUsages.append(usage)
            }
        }
        
        // Sort by date (oldest first for proper graph display)
        return graphUsages.sorted { $0.date < $1.date }
    }
    
    private var consumptionStats: (average: Double, totalCost: Double) {
        guard let vehicle = resolvedVehicle else { return (0, 0) }
        
        // Get merged groups for filtered usages
        let filteredUsages = filteredFuelUsages
        let allGroups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
        let filteredGroups = allGroups.filter { group in
            group.contains { usage in filteredUsages.contains { $0.persistentModelID == usage.persistentModelID } }
        }
        
        guard !filteredGroups.isEmpty else { return (0, 0) }
        
        var totalDistance = 0
        var totalFuel = 0.0
        var totalCost = 0.0
        
        // Sort groups by date (oldest first)
        let sortedGroups = filteredGroups.sorted { group1, group2 in
            (group1.first?.date ?? Date.distantPast) < (group2.first?.date ?? Date.distantPast)
        }
        
        var previousMileage: Int?
        
        // Process each merged group
        for group in sortedGroups {
            guard let lastUsage = group.last,
                  let endMileage = lastUsage.mileage?.value else {
                continue
            }
            
            // Sum fuel and cost for the group
            let groupFuel = group.reduce(0.0) { $0 + $1.liters }
            let groupCost = group.reduce(0.0) { $0 + $1.cost }
            
            totalFuel += groupFuel
            totalCost += groupCost
            
            // Calculate distance if we have a previous mileage
            if let prevMileage = previousMileage, endMileage > prevMileage {
                totalDistance += endMileage - prevMileage
            }
            
            previousMileage = endMileage
        }
        
        // Calculate average using fuel type-aware calculation
        let fuelType = vehicle.fuelType ?? .liquid
        let averageConsumption: Double
        if totalFuel > 0 && totalDistance > 0 {
            averageConsumption = fuelType.calculateConsumption(
                distance: Double(totalDistance),
                fuelAmount: totalFuel,
                isUsingMetric: viewModel.isUsingMetric
            ) ?? 0
        } else {
            averageConsumption = 0
        }
        
        return (averageConsumption, totalCost)
    }
    
    private var monthsInTimeframe: Int? {
        switch selectedTimeframe {
        case .all: return nil
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
//                        VehicleInfoHeader(vehicle: vehicle)
//                            .padding(.horizontal, Theme.dimensions.spacingL)
//                            .padding(.top, Theme.dimensions.spacingM)
                        
                        // Timeframe Selector
                        TimeframeSelector(selectedTimeframe: $selectedTimeframe)
                            .padding(.horizontal, Theme.dimensions.spacingL)
                            .padding(.top, Theme.dimensions.spacingM)
                        
                        // Consumption Overview Card
                        ConsumptionOverviewCard(
                            averageConsumption: consumptionStats.average,
                            totalCost: consumptionStats.totalCost,
                            fuelType: vehicle.fuelType,
                            isUsingMetric: viewModel.isUsingMetric
                        )
                        .padding(.horizontal, Theme.dimensions.spacingL)
                        .padding(.top, Theme.dimensions.spacingM)
                        
                        // Graph
                        if filteredFuelUsages.count > 1 {
                            FuelConsumptionGraphView(
                                fuelUsages: graphDataUsages,
                                vehicle: vehicle,
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
                                FuelEntriesGroupedView(
                                    fuelUsages: filteredFuelUsages,
                                    vehicle: vehicle,
                                    isUsingMetric: viewModel.isUsingMetric,
                                    onPartialFillTapped: { usage in
                                        fuelUsageForPartialFillManagement = FuelUsageSelection(id: usage.persistentModelID, fuelUsage: usage)
                                    },
                                    onEdit: { usage in
                                        fuelUsageForEditing = FuelUsageSelection(id: usage.persistentModelID, fuelUsage: usage)
                                    }
                                )
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
            .sheet(item: $fuelUsageForPartialFillManagement) { selection in
                PartialFillManagementSheet(
                    fuelUsage: selection.fuelUsage,
                    viewModel: viewModel,
                    onDismiss: {
                        fuelUsageForPartialFillManagement = nil
                        resolvedVehicle = viewModel.resolvedVehicle(context: context)
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $fuelUsageForEditing) { selection in
                EditFuelUsageSheet(
                    vehicleViewModel: viewModel,
                    fuelUsageID: selection.id
                )
                .presentationDetents([.fraction(0.65)])
                .presentationDragIndicator(.visible)
                .onDisappear {
                    resolvedVehicle = viewModel.resolvedVehicle(context: context)
                }
            }
            .onAppear {
                resolvedVehicle = viewModel.resolvedVehicle(context: context)
                
                // Track fuel details viewed
                Task { @MainActor in
                    let params: [String: Any] = [
                        "timeframe": selectedTimeframe.rawValue,
                        "fuel_entry_count": String(filteredFuelUsages.count)
                    ]
                    Scoville.track(FuelTrackrEvents.fuelDetailsViewed, parameters: params)
                    Analytics.logEvent(FuelTrackrEvents.fuelDetailsViewed.rawValue, parameters: params)
                }
            }
        }
    }
    
    private func formatFuelEntriesTitle() -> String {
        let count = filteredFuelUsages.count
        if let months = monthsInTimeframe {
            if months == 1 {
                return String(format: NSLocalizedString("fuel_entries_last_month", comment: ""), count)
            } else {
                return String(format: NSLocalizedString("fuel_entries_last_months", comment: ""), months, count)
            }
        } else {
            // All timeframe
            return String(format: NSLocalizedString("fuel_entries_all", comment: ""), count)
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
    let fuelType: FuelType?
    let isUsingMetric: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var consumptionText: String {
        let fuelTypeToUse = fuelType ?? .liquid
        return fuelTypeToUse.formatConsumption(averageConsumption, isUsingMetric: isUsingMetric)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("consumption_overview", comment: ""))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colors.onBackground)
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(consumptionText)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(colors.primary)
                    
                    Text(NSLocalizedString("average_consumption", comment: ""))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(colors.onSurface)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(totalCost))
                        .font(.system(size: 24, weight: .bold))
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
        CurrencyFormatting.format(value)
    }
}

// MARK: - Fuel Consumption Graph View

struct FuelConsumptionGraphView: View {
    let fuelUsages: [FuelUsage]
    let vehicle: Vehicle
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
        
        // Get all fuel usages sorted by date to find previous entries
        let allUsagesSorted = vehicle.fuelUsages.sorted { $0.date < $1.date }
        
        // Get merged groups
        let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
        
        for i in 0..<sortedUsages.count {
            let usage = sortedUsages[i]
            var consumption: Double = 0
            var pricePerUnit: Double = 0
            
            // Find previous closing entry or standalone full fill
            let previousUsage: FuelUsage? = {
                if let currentIndex = allUsagesSorted.firstIndex(where: { $0.persistentModelID == usage.persistentModelID }),
                   currentIndex > 0 {
                    // Look backwards to find the last closing entry or standalone full fill
                    for j in stride(from: currentIndex - 1, through: 0, by: -1) {
                        let candidate = allUsagesSorted[j]
                        
                        // Check if candidate is a closing entry or standalone full fill
                        if !candidate.isPartialFill {
                            // Check if it's part of a merged group
                            if let group = groups.first(where: { $0.contains { $0.persistentModelID == candidate.persistentModelID } }),
                               group.count > 1 {
                                // It's part of a group - check if it's the closing entry
                                let sortedGroup = group.sorted { $0.date < $1.date }
                                if let closingEntry = sortedGroup.first(where: { !$0.isPartialFill }),
                                   closingEntry.persistentModelID == candidate.persistentModelID {
                                    return candidate
                                }
                            } else {
                                // Standalone full fill
                                return candidate
                            }
                        }
                    }
                }
                return nil
            }()
            
            // Calculate consumption
            if let prevUsage = previousUsage,
               let prevMileage = prevUsage.mileage?.value {
                
                // Check if current usage is part of a merged group
                if let group = groups.first(where: { $0.contains { $0.persistentModelID == usage.persistentModelID } }),
                   group.count > 1 {
                    // Use merged group calculation
                    let sortedGroup = group.sorted { $0.date < $1.date }
                    if let closingEntry = sortedGroup.first(where: { !$0.isPartialFill }),
                       closingEntry.persistentModelID == usage.persistentModelID,
                       let endMileage = closingEntry.mileage?.value,
                       endMileage > prevMileage {
                        let totalFuel = group.reduce(0.0) { $0 + $1.liters }
                        if totalFuel > 0 {
                            let distance = Double(endMileage - prevMileage)
                            let fuelType = vehicle.fuelType ?? .liquid
                            consumption = fuelType.calculateConsumption(
                                distance: distance,
                                fuelAmount: totalFuel,
                                isUsingMetric: isUsingMetric
                            ) ?? 0
                        }
                    }
                } else if let currentMileage = usage.mileage?.value,
                          usage.liters > 0,
                          currentMileage > prevMileage {
                    // Standalone full fill - regular calculation
                    let distance = Double(currentMileage - prevMileage)
                    let fuelType = vehicle.fuelType ?? .liquid
                    consumption = fuelType.calculateConsumption(
                        distance: distance,
                        fuelAmount: usage.liters,
                        isUsingMetric: isUsingMetric
                    ) ?? 0
                }
            }
            
            // Calculate price per unit
            if let group = groups.first(where: { $0.contains { $0.persistentModelID == usage.persistentModelID } }),
               group.count > 1 {
                // Merged group - use total fuel and cost
                let totalFuel = group.reduce(0.0) { $0 + $1.liters }
                let totalCost = group.reduce(0.0) { $0 + $1.cost }
                if totalFuel > 0 {
                    if isUsingMetric {
                        pricePerUnit = totalCost / totalFuel // €/L
                    } else {
                        let gallons = totalFuel * 0.264172
                        pricePerUnit = gallons > 0 ? totalCost / gallons : 0 // $/gal
                    }
                }
            } else if usage.liters > 0 {
                // Standalone entry
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
        let fuelType = vehicle.fuelType ?? .liquid
        switch (fuelType, isUsingMetric) {
        case (.liquid, true): return NSLocalizedString("km_per_liter", comment: "")
        case (.liquid, false): return "mpg"
        case (.electric, true): return "kWh/100km"
        case (.electric, false): return "mi/kWh"
        case (.hydrogen, true): return "kg H₂/100km"
        case (.hydrogen, false): return "mi/kg H₂"
        case (.unknown, _): return "-"
        }
    }
    
    private var priceUnit: String {
        if isUsingMetric {
            let currency = GetSelectedCurrencyUseCase()()
            return "\(currency.symbol)/L"
        } else {
            return NSLocalizedString("price_per_gallon", comment: "")
        }
    }
    
    private func formatPrice(_ value: Double) -> String {
        CurrencyFormatting.format(value)
    }
    
    private var consumptionData: [(date: Date, value: Double)] {
        // Group by day and calculate cumulative consumption
        let calendar = Calendar.current
        var dailyData: [Date: (consumption: Double, count: Int)] = [:]
        
        for dataPoint in graphData where dataPoint.consumption > 0 {
            let dayStart = calendar.startOfDay(for: dataPoint.date)
            if let existing = dailyData[dayStart] {
                // Average consumption for the day (or sum, depending on what makes sense)
                // For now, let's average multiple entries on the same day
                let totalConsumption = existing.consumption * Double(existing.count) + dataPoint.consumption
                dailyData[dayStart] = (consumption: totalConsumption / Double(existing.count + 1), count: existing.count + 1)
            } else {
                dailyData[dayStart] = (consumption: dataPoint.consumption, count: 1)
            }
        }
        
        // Convert to array and sort by date
        return dailyData.map { (date: $0.key, value: $0.value.consumption) }
            .sorted { $0.date < $1.date }
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
    
    private var xAxisDates: [Date] {
        guard !consumptionData.isEmpty else { return [] }
        let dates = consumptionData.map { $0.date }
        guard let minDate = dates.min(), let maxDate = dates.max() else { return [] }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: minDate, to: maxDate).day ?? 0
        let desiredCount = min(5, max(2, days + 1))
        
        var axisDates: [Date] = []
        if days <= desiredCount {
            // If we have few days, show all dates
            axisDates = dates
        } else {
            // Distribute dates evenly
            let step = max(1, days / (desiredCount - 1))
            for i in 0..<desiredCount {
                if let date = calendar.date(byAdding: .day, value: i * step, to: minDate) {
                    axisDates.append(date)
                }
            }
            // Always include the last date
            if !axisDates.contains(maxDate) {
                axisDates.append(maxDate)
            }
        }
        return axisDates.sorted()
    }
    
    private var yAxisValues: [Double] {
        let range = consumptionRange
        let min = range.min
        let max = range.max
        let step = (max - min) / 4.0 // 5 marks total (including min and max)
        
        var values: [Double] = []
        for i in 0...4 {
            let value = min + (step * Double(i))
            values.append(value)
        }
        return values
    }
    
    @ViewBuilder
    private var consumptionChart: some View {
        let consumptionRangeValues = consumptionRange
        let hasConsumption = !consumptionData.isEmpty
        
        if hasConsumption {
            let yAxisMin = consumptionRangeValues.min
            let yAxisMax = consumptionRangeValues.max
            let averageConsumption = consumptionData.map { $0.value }.reduce(0, +) / Double(consumptionData.count)
            
            VStack(alignment: .leading, spacing: 12) {
                // Chart Title
                Text(NSLocalizedString("consumption_over_time", comment: "Consumption Over Time"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colors.onBackground)
                
                Chart {
                    // Area fill under the line
                    ForEach(consumptionData, id: \.date) { dataPoint in
                        AreaMark(
                            x: .value("Date", dataPoint.date),
                            yStart: .value("Min", yAxisMin),
                            yEnd: .value("Consumption", dataPoint.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    colors.primary.opacity(0.3),
                                    colors.primary.opacity(0.1),
                                    Color.clear
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                    
                    // Average consumption reference line
                    RuleMark(y: .value("Average", averageConsumption))
                        .foregroundStyle(colors.onSurface.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing, spacing: 4) {
                            Text(String(format: "%.1f", averageConsumption))
                                .font(.caption2)
                                .foregroundColor(colors.onSurface.opacity(0.7))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(colors.surface.opacity(0.9))
                                .cornerRadius(4)
                        }
                    
                    // Main consumption line
                    ForEach(consumptionData, id: \.date) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Consumption", dataPoint.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    colors.primary,
                                    colors.secondary
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        
                        // Data points
                        PointMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Consumption", dataPoint.value)
                        )
                        .foregroundStyle(colors.primary)
                        .symbolSize(50)
                        .symbol(.circle)
                        .opacity(0.9)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(formatGraphDate(date))
                                    .font(.caption2)
                                    .foregroundColor(colors.onSurface)
                            }
                        }
                        AxisGridLine()
                            .foregroundStyle(colors.divider.opacity(0.5))
                        AxisTick()
                            .foregroundStyle(colors.onSurface.opacity(0.3))
                    }
                }
                .chartYScale(domain: yAxisMin...yAxisMax)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(String(format: "%.1f", doubleValue))
                                    .font(.caption2)
                                    .foregroundColor(colors.onSurface)
                            }
                        }
                        AxisGridLine()
                            .foregroundStyle(colors.divider.opacity(0.5))
                        AxisTick()
                            .foregroundStyle(colors.onSurface.opacity(0.3))
                    }
                }
                .chartXAxisLabel(NSLocalizedString("date", comment: ""), position: .bottom, alignment: .center)
                .chartYAxisLabel(consumptionUnit, position: .leading, alignment: .center)
                .frame(height: 240)
                .padding(.top, 4)
                .padding(.bottom, 4)
                .padding(.leading, 4)
                .padding(.trailing, 12)
            }
        } else {
            VStack(spacing: 12) {
                Text(NSLocalizedString("consumption_over_time", comment: "Consumption Over Time"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colors.onBackground)
                
                Text(NSLocalizedString("fuel_usage_no_content", comment: ""))
                    .font(.caption)
                    .foregroundColor(colors.onSurface)
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
            }
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
    let isClosingEntry: Bool
    let isUsingMetric: Bool
    let onPartialFillTapped: (() -> Void)?
    let onEdit: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        usage: FuelUsage,
        nextUsage: FuelUsage?,
        isClosingEntry: Bool = false,
        isUsingMetric: Bool = true,
        onPartialFillTapped: (() -> Void)? = nil,
        onEdit: (() -> Void)? = nil
    ) {
        self.usage = usage
        self.nextUsage = nextUsage
        self.isClosingEntry = isClosingEntry
        self.isUsingMetric = isUsingMetric
        self.onPartialFillTapped = onPartialFillTapped
        self.onEdit = onEdit
    }
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var startMileage: Int {
        // For grouped entries, we need to find the correct previous mileage
        // If this is a partial fill in a group, use the mileage from the next entry in the group (newer chronologically)
        // Otherwise, use nextUsage (which is the previous entry chronologically)
        if usage.isPartialFill, let vehicle = usage.vehicle {
            let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
            if let group = groups.first(where: { $0.contains { $0.persistentModelID == usage.persistentModelID } }) {
                // Find this usage's position in the group (sorted by date, oldest to newest)
                let sortedGroup = group.sorted { $0.date < $1.date }
                if let currentIndex = sortedGroup.firstIndex(where: { $0.persistentModelID == usage.persistentModelID }),
                   currentIndex > 0 {
                    // Use the mileage from the previous entry in the group (which is older chronologically)
                    return sortedGroup[currentIndex - 1].mileage?.value ?? (usage.mileage?.value ?? 0)
                } else if let currentIndex = sortedGroup.firstIndex(where: { $0.persistentModelID == usage.persistentModelID }),
                          currentIndex == 0 {
                    // This is the first entry in the group, find the mileage before the group started
                    let sortedAllUsages = vehicle.fuelUsages.sorted { $0.date < $1.date }
                    if let groupFirstIndex = sortedAllUsages.firstIndex(where: { $0.persistentModelID == sortedGroup[0].persistentModelID }),
                       groupFirstIndex > 0 {
                        return sortedAllUsages[groupFirstIndex - 1].mileage?.value ?? (usage.mileage?.value ?? 0)
                    }
                }
            }
        }
        
        // For non-partial fills or single entries, use nextUsage (previous entry chronologically)
        return nextUsage?.mileage?.value ?? (usage.mileage?.value ?? 0)
    }
    
    private var endMileage: Int {
        usage.mileage?.value ?? 0
    }
    
    private var consumption: Double? {
        // If this is a partial fill, calculate using merged group
        if usage.isPartialFill, let vehicle = usage.vehicle {
            let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
            if let group = groups.first(where: { $0.contains { $0.persistentModelID == usage.persistentModelID } }) {
                // Find previous mileage before this group
                let sorted = vehicle.fuelUsages.sorted { $0.date < $1.date }
                guard let groupIndex = sorted.firstIndex(where: { $0.persistentModelID == usage.persistentModelID }),
                      groupIndex > 0,
                      let previousMileage = sorted[groupIndex - 1].mileage?.value else {
                    return nil
                }
                guard let vehicle = usage.vehicle else { return nil }
                return FuelUsageMergingHelper.calculateConsumptionForGroup(
                    group,
                    previousMileage: previousMileage,
                    fuelType: vehicle.fuelType,
                    isUsingMetric: isUsingMetric
                )
            }
        }
        
        // Regular calculation for full fills
        guard let currentMileage = usage.mileage?.value,
              let previousMileage = nextUsage?.mileage?.value,
              usage.liters > 0,
              currentMileage > previousMileage,
              let vehicle = usage.vehicle else {
            return nil
        }
        let distance = Double(currentMileage - previousMileage)
        let fuelType = vehicle.fuelType ?? .liquid
        return fuelType.calculateConsumption(
            distance: distance,
            fuelAmount: usage.liters,
            isUsingMetric: isUsingMetric
        )
    }
    
    private var range: Double? {
        guard let consumption = consumption else { return nil }
        
        // If this is a partial fill, use merged group fuel amount
        if usage.isPartialFill, let vehicle = usage.vehicle {
            let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
            if let group = groups.first(where: { $0.contains { $0.persistentModelID == usage.persistentModelID } }) {
                let totalFuel = group.reduce(0.0) { $0 + $1.liters }
                return consumption * totalFuel
            }
        }
        
        return consumption * usage.liters
    }
    
    private var pricePerLiter: Double {
        usage.liters > 0 ? usage.cost / usage.liters : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Date/Time and Mileage Range
            HStack {
                // Date and Time (blue, left)
                HStack(spacing: 6) {
                    Text(formatDateTime(usage.date))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(colors.primary)
                    
                    // Closing Entry Badge
                    if isClosingEntry {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text(NSLocalizedString("closing_fill", comment: ""))
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(colors.primary)
                        .cornerRadius(6)
                    }
                }
                
                // Partial Fill Badge
                if usage.isPartialFill {
                    Button(action: {
                        onPartialFillTapped?()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                            Text(NSLocalizedString("partial_fill_badge", comment: ""))
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(colorScheme == .dark ? Color.orange : Color.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Color.orange.opacity(colorScheme == .dark ? 0.25 : 0.15)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(colorScheme == .dark ? 0.5 : 0.3), lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // Mileage Range (gray, right)
                Text("\(startMileage.formattedWithSeparator) -> \(endMileage.formattedWithSeparator) km")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(colors.onSurface)
            }
            
            // First Row of Pills: Fuel Amount, Price/Unit, Total Cost
            HStack(spacing: 8) {
                // Fuel Amount (Red/purple pill matching FuelConsumptionEntryView)
                if let vehicle = usage.vehicle {
                    let fuelType = vehicle.fuelType ?? .liquid
                    let fuelText = fuelType.formatFuelAmount(usage.liters, isUsingMetric: isUsingMetric)
                    FuelPill(
                        icon: "car.fill",
                        text: fuelText.replacingOccurrences(of: ".", with: ","),
                        backgroundColor: colors.accentRedLight,
                        iconColor: colors.accentRed,
                        textColor: colorScheme == .dark ? colors.accentRed : hexColor("#613E8D") // Adaptive: red in dark mode, dark purple in light
                    )
                    
                    // Price per unit (Green pill matching FuelConsumptionEntryView)
                    if usage.liters > 0 {
                        let priceText = fuelType.formatPricePerUnit(pricePerLiter, isUsingMetric: isUsingMetric, currency: GetSelectedCurrencyUseCase()())
                        FuelPill(
                            icon: "fuelpump.fill",
                            text: priceText.replacingOccurrences(of: ".", with: ","),
                            backgroundColor: colors.accentGreenLight,
                            iconColor: colors.accentGreen,
                            textColor: colorScheme == .dark ? colors.accentGreen : hexColor("#306B42") // Adaptive: green in dark mode, dark green in light
                        )
                    }
                } else {
                    // Fallback for when vehicle is not available
                    FuelPill(
                        icon: "car.fill",
                        text: String(format: "%.2f", usage.liters).replacingOccurrences(of: ".", with: ",") + "L",
                        backgroundColor: colors.accentRedLight,
                        iconColor: colors.accentRed,
                        textColor: colorScheme == .dark ? colors.accentRed : hexColor("#613E8D")
                    )
                    
                    if usage.liters > 0 {
                        FuelPill(
                            icon: "fuelpump.fill",
                            text: formatPricePerLiter(pricePerLiter),
                            backgroundColor: colors.accentGreenLight,
                            iconColor: colors.accentGreen,
                            textColor: colorScheme == .dark ? colors.accentGreen : hexColor("#306B42")
                        )
                    }
                }
                
                // Total cost (Orange pill matching FuelConsumptionEntryView)
                FuelPill(
                    icon: "dollarsign.circle.fill",
                    text: formatCurrency(usage.cost),
                    backgroundColor: colors.accentOrangeLight,
                    iconColor: colors.accentOrange,
                    textColor: colorScheme == .dark ? colors.accentOrange : hexColor("#8F6126") // Adaptive: orange in dark mode, dark orange in light
                )
                
                Spacer()
            }
            
            // Second Row of Pills: Consumption, Distance Driven
            HStack(spacing: 8) {
                // Consumption (show for non-partial fills, but hide for closing entries in groups since combined stats shows it)
                if !usage.isPartialFill && !isClosingEntry, let consumption = consumption, let vehicle = usage.vehicle {
                    let fuelType = vehicle.fuelType ?? .liquid
                    let consumptionText = fuelType.formatConsumption(consumption, isUsingMetric: isUsingMetric)
                    FuelPill(
                        icon: "fuelpump.fill",
                        text: consumptionText.replacingOccurrences(of: ".", with: ","),
                        backgroundColor: colors.fuelUsagePillBackground,
                        iconColor: colors.fuelUsagePillText,
                        textColor: colors.fuelUsagePillText
                    )
                }
                
                // Distance Driven (show for all entries, including partial fills)
                let distanceDriven = endMileage - startMileage
                if distanceDriven > 0 {
                    FuelPill(
                        icon: "speedometer",
                        text: String(format: "%d", distanceDriven).replacingOccurrences(of: ".", with: ",") + " km",
                        backgroundColor: colors.kmDrivenPillBackground,
                        iconColor: colors.kmDrivenPillText,
                        textColor: colors.kmDrivenPillText
                    )
                }
                
                Spacer()
            }
        }
        .padding(Theme.dimensions.spacingM)
        .background(colors.surface)
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit?()
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMM yyyy - HH:mm"
        return formatter.string(from: date).lowercased()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        CurrencyFormatting.format(value)
    }
    
    private func formatPricePerLiter(_ value: Double) -> String {
        CurrencyFormatting.formatPricePerLiter(value)
    }
}

// MARK: - Fuel Entries Grouped View

struct FuelEntriesGroupedView: View {
    let fuelUsages: [FuelUsage]
    let vehicle: Vehicle
    let isUsingMetric: Bool
    let onPartialFillTapped: (FuelUsage) -> Void
    let onEdit: (FuelUsage) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var groupedEntries: [(isGrouped: Bool, entries: [FuelUsage])] {
        // Get merged groups
        let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
        
        // Sort fuel usages by date (newest first, matching the filtered list order)
        let sortedUsages = fuelUsages.sorted { $0.date > $1.date }
        var result: [(isGrouped: Bool, entries: [FuelUsage])] = []
        var processedIDs = Set<PersistentIdentifier>()
        
        for usage in sortedUsages {
            // Skip if already processed
            if processedIDs.contains(usage.persistentModelID) {
                continue
            }
            
            // Check if this usage is part of a merged group
            if let group = groups.first(where: { $0.contains { $0.persistentModelID == usage.persistentModelID } }),
               group.count > 1 {
                // Filter group entries that are in the filtered list and sort by date (newest first)
                let fuelUsageIDs = Set(fuelUsages.map { $0.persistentModelID })
                let groupEntries = group
                    .filter { fuelUsageIDs.contains($0.persistentModelID) }
                    .sorted { $0.date > $1.date }
                
                if !groupEntries.isEmpty {
                    result.append((isGrouped: true, entries: groupEntries))
                    groupEntries.forEach { processedIDs.insert($0.persistentModelID) }
                }
            } else {
                // Single entry, not grouped
                result.append((isGrouped: false, entries: [usage]))
                processedIDs.insert(usage.persistentModelID)
            }
        }
        
        return result
    }
    
    private func findClosingEntry(in group: [FuelUsage]) -> FuelUsage? {
        // Find the last entry that is NOT a partial fill (the closing full fill)
        // Groups are sorted newest first, so we need to find the oldest non-partial entry
        let sortedByDate = group.sorted { $0.date < $1.date }
        return sortedByDate.first { !$0.isPartialFill }
    }
    
    @ViewBuilder
    private func connectingLineView(closingIndex: Int?, entryCount: Int) -> some View {
        GeometryReader { geometry in
            if let closingIdx = closingIndex {
                let entryHeight: CGFloat = 60
                let spacing: CGFloat = Theme.dimensions.spacingM
                let totalHeight = CGFloat(entryCount) * entryHeight + CGFloat(entryCount - 1) * spacing
                let lineX = Theme.dimensions.spacingL + Theme.dimensions.spacingM + 2
                let startY = Theme.dimensions.spacingM
                let endY = totalHeight + Theme.dimensions.spacingM
                
                ZStack {
                    // Draw continuous line
                    Path { path in
                        path.move(to: CGPoint(x: lineX, y: startY))
                        path.addLine(to: CGPoint(x: lineX, y: endY))
                    }
                    .stroke(Color.orange.opacity(colorScheme == .dark ? 0.6 : 0.4), lineWidth: 4)
                    
                    // Draw dot at closing entry position
                    let closingY = startY + (CGFloat(closingIdx) * (entryHeight + spacing)) + (entryHeight / 2)
                    Circle()
                        .fill(Color.orange.opacity(colorScheme == .dark ? 0.9 : 0.8))
                        .frame(width: 8, height: 8)
                        .position(x: lineX, y: closingY)
                }
            }
        }
        .frame(height: calculateTotalHeight(entryCount: entryCount))
    }
    
    private func calculateTotalHeight(entryCount: Int) -> CGFloat {
        let entryHeight: CGFloat = 60
        let spacing: CGFloat = Theme.dimensions.spacingM
        return CGFloat(entryCount) * entryHeight + CGFloat(entryCount - 1) * spacing + Theme.dimensions.spacingM * 2
    }
    
    private func entriesView(
        entries: [FuelUsage],
        closingEntry: FuelUsage?,
        onPartialFillTapped: @escaping (FuelUsage) -> Void,
        onEdit: @escaping (FuelUsage) -> Void
    ) -> some View {
        // Sort entries chronologically (oldest to newest) to find correct previous mileage
        let sortedEntries = entries.sorted { $0.date < $1.date }
        
        return VStack(spacing: Theme.dimensions.spacingM) {
            // Display entries in reverse order (newest first) but use chronological order for finding previous
            ForEach(Array(entries.enumerated()), id: \.element.persistentModelID) { index, usage in
                let isClosingEntry = closingEntry?.persistentModelID == usage.persistentModelID
                
                // Find the previous entry chronologically (older)
                let previousUsage: FuelUsage? = {
                    if let currentIndex = sortedEntries.firstIndex(where: { $0.persistentModelID == usage.persistentModelID }),
                       currentIndex > 0 {
                        return sortedEntries[currentIndex - 1]
                    }
                    return nil
                }()
                
                DetailedFuelEntryRow(
                    usage: usage,
                    nextUsage: previousUsage,
                    isClosingEntry: isClosingEntry,
                    isUsingMetric: isUsingMetric,
                    onPartialFillTapped: {
                        onPartialFillTapped(usage)
                    },
                    onEdit: {
                        onEdit(usage)
                    }
                )
            }
        }
    }
    
    private func groupSummaryStats(for group: [FuelUsage], isUsingMetric: Bool) -> (totalFuel: Double, totalCost: Double, totalDistance: Int, consumption: Double?) {
        let sortedGroup = group.sorted { $0.date < $1.date }
        let totalFuel = group.reduce(0.0) { $0 + $1.liters }
        let totalCost = group.reduce(0.0) { $0 + $1.cost }
        
        // Find start and end mileage for the group
        guard let firstUsage = sortedGroup.first,
              let lastUsage = sortedGroup.last,
              let endMileage = lastUsage.mileage?.value else {
            return (totalFuel, totalCost, 0, nil)
        }
        
        // Find start mileage (before the group started)
        let sortedAllUsages = vehicle.fuelUsages.sorted { $0.date < $1.date }
        let startMileage: Int
        if let firstIndex = sortedAllUsages.firstIndex(where: { $0.persistentModelID == firstUsage.persistentModelID }),
           firstIndex > 0 {
            startMileage = sortedAllUsages[firstIndex - 1].mileage?.value ?? (firstUsage.mileage?.value ?? endMileage)
        } else {
            startMileage = firstUsage.mileage?.value ?? endMileage
        }
        
        let totalDistance = max(0, endMileage - startMileage)
        let fuelType = vehicle.fuelType ?? .liquid
        let consumption: Double? = totalFuel > 0 && totalDistance > 0 ? fuelType.calculateConsumption(
            distance: Double(totalDistance),
            fuelAmount: totalFuel,
            isUsingMetric: isUsingMetric
        ) : nil
        
        return (totalFuel, totalCost, totalDistance, consumption)
    }
    
    var body: some View {
        ForEach(Array(groupedEntries.enumerated()), id: \.offset) { groupIndex, group in
            if group.isGrouped {
                // Merged group with visual styling
                let closingEntry = findClosingEntry(in: group.entries)
                let closingIndex = closingEntry.flatMap { close in
                    group.entries.firstIndex { $0.persistentModelID == close.persistentModelID }
                }
                
                let entries = group.entries
                let summaryStats = groupSummaryStats(for: entries, isUsingMetric: isUsingMetric)
                let vehicleFuelType = vehicle.fuelType
                
                VStack(alignment: .leading, spacing: Theme.dimensions.spacingM) {
                    // Combined Stats Summary Card
                    GroupSummaryCard(
                        totalFuel: summaryStats.totalFuel,
                        totalCost: summaryStats.totalCost,
                        totalDistance: summaryStats.totalDistance,
                        consumption: summaryStats.consumption,
                        fuelType: vehicleFuelType,
                        isUsingMetric: isUsingMetric
                    )
                    
                    ZStack(alignment: .leading) {
                        // Continuous vertical line connecting all entries
                        let entryCount = entries.count
                        connectingLineView(closingIndex: closingIndex, entryCount: entryCount)
                        
                        // Entries with spacing
                        entriesView(
                            entries: entries,
                            closingEntry: closingEntry,
                            onPartialFillTapped: onPartialFillTapped,
                            onEdit: onEdit
                        )
                    }
                }
                .padding(Theme.dimensions.spacingM)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(colorScheme == .dark ? 0.15 : 0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(colorScheme == .dark ? 0.6 : 0.4), lineWidth: 1.5)
                        )
                )
                .padding(.horizontal, Theme.dimensions.spacingL)
                .padding(.vertical, Theme.dimensions.spacingM / 2)
            } else {
                // Single entry (not part of a group, so no closing badge)
                // For single entries, we need to find the previous usage for consumption calculation
                let singleUsage = group.entries[0]
                let sortedAllUsages = vehicle.fuelUsages.sorted { $0.date < $1.date }
                let previousUsage: FuelUsage? = {
                    if let currentIndex = sortedAllUsages.firstIndex(where: { $0.persistentModelID == singleUsage.persistentModelID }),
                       currentIndex > 0 {
                        return sortedAllUsages[currentIndex - 1]
                    }
                    return nil
                }()
                
                DetailedFuelEntryRow(
                    usage: singleUsage,
                    nextUsage: previousUsage,
                    isClosingEntry: false,
                    isUsingMetric: isUsingMetric,
                    onPartialFillTapped: {
                        onPartialFillTapped(singleUsage)
                    },
                    onEdit: {
                        onEdit(singleUsage)
                    }
                )
                .padding(.horizontal, Theme.dimensions.spacingL)
                .padding(.vertical, Theme.dimensions.spacingM / 2)
            }
        }
    }
}

// MARK: - Group Summary Card

struct GroupSummaryCard: View {
    let totalFuel: Double
    let totalCost: Double
    let totalDistance: Int
    let consumption: Double?
    let fuelType: FuelType?
    let isUsingMetric: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        CurrencyFormatting.format(value)
    }
    
    private var pricePerLiter: Double {
        totalFuel > 0 ? totalCost / totalFuel : 0
    }
    
    private func formatPricePerLiter(_ value: Double) -> String {
        CurrencyFormatting.formatPricePerLiter(value)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title on one line
            Text(NSLocalizedString("combined_stats", comment: "Combined Statistics"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.onBackground)
            
            // First Row of Pills: Liters, Price/L, Total Cost
            HStack(spacing: 8) {
                // Total Fuel (Red/purple pill matching FuelConsumptionEntryView)
                let fuelTypeToUse = fuelType ?? .liquid
                let fuelText = fuelTypeToUse.formatFuelAmount(totalFuel, isUsingMetric: isUsingMetric)
                FuelPill(
                    icon: "car.fill",
                    text: fuelText.replacingOccurrences(of: ".", with: ","),
                    backgroundColor: colors.accentRedLight,
                    iconColor: colors.accentRed,
                    textColor: colorScheme == .dark ? colors.accentRed : hexColor("#613E8D") // Adaptive: red in dark mode, dark purple in light
                )
                
                // Price per unit (Green pill matching FuelConsumptionEntryView)
                if totalFuel > 0 {
                    let priceText = fuelTypeToUse.formatPricePerUnit(pricePerLiter, isUsingMetric: isUsingMetric, currency: GetSelectedCurrencyUseCase()())
                    FuelPill(
                        icon: "fuelpump.fill",
                        text: priceText.replacingOccurrences(of: ".", with: ","),
                        backgroundColor: colors.accentGreenLight,
                        iconColor: colors.accentGreen,
                        textColor: colorScheme == .dark ? colors.accentGreen : hexColor("#306B42") // Adaptive: green in dark mode, dark green in light
                    )
                }
                
                // Total Cost (Orange pill matching FuelConsumptionEntryView)
                FuelPill(
                    icon: "dollarsign.circle.fill",
                    text: formatCurrency(totalCost),
                    backgroundColor: colors.accentOrangeLight,
                    iconColor: colors.accentOrange,
                    textColor: colorScheme == .dark ? colors.accentOrange : hexColor("#8F6126") // Adaptive: orange in dark mode, dark orange in light
                )
                
                Spacer()
            }
            
            // Second Row of Pills: Consumption, Distance Driven
            HStack(spacing: 8) {
                // Consumption (if available)
                if let consumption = consumption {
                    let fuelTypeToUse = fuelType ?? .liquid
                    let consumptionText = fuelTypeToUse.formatConsumption(consumption, isUsingMetric: isUsingMetric)
                    FuelPill(
                        icon: "fuelpump.fill",
                        text: consumptionText.replacingOccurrences(of: ".", with: ","),
                        backgroundColor: colors.fuelUsagePillBackground,
                        iconColor: colors.fuelUsagePillText,
                        textColor: colors.fuelUsagePillText
                    )
                }
                
                // Total Distance
                if totalDistance > 0 {
                    FuelPill(
                        icon: "speedometer",
                        text: String(format: "%d", totalDistance).replacingOccurrences(of: ".", with: ",") + " km",
                        backgroundColor: colors.kmDrivenPillBackground,
                        iconColor: colors.kmDrivenPillText,
                        textColor: colors.kmDrivenPillText
                    )
                }
                
                Spacer()
            }
        }
        .padding(Theme.dimensions.spacingM)
        .background(colors.surface)
        .cornerRadius(12)
    }
}

// MARK: - Fuel Pill

struct FuelPill: View {
    let icon: String
    let text: String
    let backgroundColor: Color
    let iconColor: Color
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(iconColor)
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

