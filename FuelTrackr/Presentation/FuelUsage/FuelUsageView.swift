// MARK: - Package: Presentation

//
//  FuelUsageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain
import Charts

public struct FuelUsageView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAddFuelSheet: Bool

    @Environment(\.modelContext) private var context
    @State private var showAllFuelEntries = false
    @State private var resolvedVehicle: Vehicle?

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(NSLocalizedString("fuel_usage_title", comment: ""))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: { showAddFuelSheet = true }) {
                    Label(NSLocalizedString("add", comment: ""), systemImage: "plus")
                        .labelStyle(.titleAndIcon)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .cornerRadius(8)
                }

                Button(action: { showAllFuelEntries = true }) {
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }

            if let vehicle = resolvedVehicle {
                FuelUsageListView(vehicle: vehicle)
            } else {
                Text(NSLocalizedString("fuel_usage_no_content", comment: ""))
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .sheet(isPresented: $showAllFuelEntries) {
            FuelDetailsSheet(viewModel: viewModel, showAddFuelSheet: $showAddFuelSheet)
        }
        .onAppear {
            resolvedVehicle = viewModel.resolvedVehicle(context: context)
        }
    }
}

// MARK: - FuelUsageListView

public struct FuelUsageListView: View {
    public let vehicle: Vehicle
    @StateObject private var settingsViewModel = SettingsViewModel()

    public var body: some View {
        let fuelUsages = vehicle.fuelUsages.sorted(by: { $0.date > $1.date })

        if !fuelUsages.isEmpty {
            let latestEntries = Array(fuelUsages.prefix(3))

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(latestEntries.enumerated()), id: \.element.id) { index, usage in
                    let nextUsage = index < latestEntries.count - 1 ? latestEntries[index + 1] : nil
                    FuelUsageRow(usage: usage, nextUsage: nextUsage, colorIndex: index, isUsingMetric: settingsViewModel.isUsingMetric)
                }
                if latestEntries.count < 3 {
                    ForEach(latestEntries.count..<3, id: \.self) { index in
                        SkeletonFuelUsageRow(colorIndex: index)
                    }
                }
            }
        } else {
            Text(NSLocalizedString("fuel_usage_no_content", comment: ""))
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - FuelUsageRow

public struct FuelUsageRow: View {
    let usage: FuelUsage
    let nextUsage: FuelUsage?
    let colorIndex: Int
    let isUsingMetric: Bool
    
    // Get merged group for this usage if it's part of a partial fill group
    private var mergedGroup: [FuelUsage]? {
        guard let vehicle = usage.vehicle else { return nil }
        let groups = FuelUsageMergingHelper.groupMergedFuelUsages(vehicle.fuelUsages)
        return groups.first { group in group.contains { $0.persistentModelID == usage.persistentModelID } }
    }
    
    private func formatFuelAndCost(usage: FuelUsage) -> String {
        guard let vehicle = usage.vehicle else {
            // Fallback: use default formatting
            let fuelFormatter = NumberFormatter()
            fuelFormatter.minimumFractionDigits = 0
            fuelFormatter.maximumFractionDigits = 2
            let fuelText = fuelFormatter.string(from: NSNumber(value: usage.liters)) ?? String(format: "%.2f", usage.liters)
            let costText = CurrencyFormatting.format(usage.cost)
            return "\(fuelText) \(NSLocalizedString("unit_l", comment: "")), \(costText)"
        }
        let fuelType = vehicle.fuelType ?? .liquid
        let fuelText = fuelType.formatFuelAmount(usage.liters, isUsingMetric: isUsingMetric)
        let costText = CurrencyFormatting.format(usage.cost)
        return "\(fuelText), \(costText)"
    }

    var consumption: Double? {
        // If this is a partial fill, calculate using merged group
        if usage.isPartialFill, let group = mergedGroup, let vehicle = usage.vehicle {
            let sorted = vehicle.fuelUsages.sorted { $0.date < $1.date }
            guard let groupIndex = sorted.firstIndex(where: { $0.persistentModelID == usage.persistentModelID }),
                  groupIndex > 0,
                  let previousMileage = sorted[groupIndex - 1].mileage?.value,
                  let lastUsage = group.last,
                  let endMileage = lastUsage.mileage?.value,
                  endMileage > previousMileage else {
                return nil
            }
            let totalFuel = group.reduce(0.0) { $0 + $1.liters }
            guard totalFuel > 0 else { return nil }
            let distance = Double(endMileage - previousMileage)
            let fuelType = vehicle.fuelType ?? .liquid
            return fuelType.calculateConsumption(
                distance: distance,
                fuelAmount: totalFuel,
                isUsingMetric: isUsingMetric
            )
        }
        
        // Regular calculation for full fills
        guard let vehicle = usage.vehicle,
              let current = usage.mileage?.value,
              let previous = nextUsage?.mileage?.value,
              usage.liters > 0,
              current > previous else {
            return nil
        }
        let distance = Double(current - previous)
        let fuelType = vehicle.fuelType ?? .liquid
        return fuelType.calculateConsumption(
            distance: distance,
            fuelAmount: usage.liters,
            isUsingMetric: isUsingMetric
        )
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(usage.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text(formatFuelAndCost(usage: usage))
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                if usage.liters > 0, let vehicle = usage.vehicle {
                    let fuelType = vehicle.fuelType ?? .liquid
                    let pricePerUnit = usage.cost / usage.liters
                    Text(fuelType.formatPricePerUnit(pricePerUnit, isUsingMetric: isUsingMetric, currency: GetSelectedCurrencyUseCase()()))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                if let consumption = consumption, let vehicle = usage.vehicle {
                    let fuelType = vehicle.fuelType ?? .liquid
                    Text(fuelType.formatConsumption(consumption, isUsingMetric: isUsingMetric))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 75, alignment: .leading)
        .background(colorIndex.isMultiple(of: 2) ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
    }
}

// MARK: - SkeletonFuelUsageRow

public struct SkeletonFuelUsageRow: View {
    let colorIndex: Int
    @State private var isAnimating = false

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 10)
                    .shimmerEffect(isAnimating: isAnimating)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 12)
                    .shimmerEffect(isAnimating: isAnimating)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 12)
                .shimmerEffect(isAnimating: isAnimating)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 75, alignment: .leading)
        .background(colorIndex.isMultiple(of: 2) ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Effect

public struct ShimmerEffectModifier: ViewModifier {
    let isAnimating: Bool

    public func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.6 : 1.0)
            .overlay(
                GeometryReader { geometry in
                    Color.white
                        .opacity(0.4)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .white.opacity(0.6), .clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                }
            )
    }
}

public extension View {
    func shimmerEffect(isAnimating: Bool) -> some View {
        modifier(ShimmerEffectModifier(isAnimating: isAnimating))
    }
}
