//
//  FuelUsageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI
import Charts

// MARK: - FuelUsageView

struct FuelUsageView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAddFuelSheet: Bool
    var isVehicleActive: Bool
    @State private var showAllFuelEntries = false
    @State private var selectedTab = 0
    @State private var tabHeight: CGFloat = 200

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(NSLocalizedString("fuel_usage_title", comment: ""))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: { showAddFuelSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(NSLocalizedString("add", comment: ""))
                    }
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isVehicleActive ? Color.orange : Color.gray.opacity(0.5))
                    .cornerRadius(8)
                }
                .disabled(!isVehicleActive)
                
                Button(action: {
                    showAllFuelEntries = true
                }) {
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isVehicleActive ? Color.orange : Color.gray.opacity(0.5))
                        .cornerRadius(8)
                }
                .disabled(!isVehicleActive)
            }

            // Main content (tabbed view)
            VStack(spacing: 8) {
                TabView(selection: $selectedTab) {
                    FuelUsageListView(viewModel: viewModel, showAllFuelEntries: $showAllFuelEntries)
                        .tag(0)

                    if let vehicle = viewModel.activeVehicle, vehicle.fuelUsages.count > 1 {
                        FuelUsageGraphView(fuelHistory: vehicle.fuelUsages)
                            .tag(1)
                            .onAppear {
                                let counter = if vehicle.fuelUsages.count > 3 { vehicle.fuelUsages.count } else { vehicle.fuelUsages.count }
                                tabHeight = CGFloat(counter * 75)
                            }
                    } else {
                        Text(NSLocalizedString("no_graph_fuel", comment: ""))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .tag(1)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: tabHeight)

                // Tab indicators
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 0 ? .blue : .gray)

                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 1 ? .blue : .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .sheet(isPresented: $showAllFuelEntries) {
            AllFuelUsageView(viewModel: viewModel)
        }
        .onAppear {
            print("FuelUsageView appeared. Initial tab height: \(tabHeight)")
        }
    }
}

struct FuelUsageListView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAllFuelEntries: Bool

    var body: some View {
        if let fuelUsages = viewModel.activeVehicle?.fuelUsages.sorted(by: { $0.date > $1.date }),
           !fuelUsages.isEmpty {
            // Limit to a maximum of 3 entries
            let latestEntries = Array(fuelUsages.prefix(3))
            
            VStack(alignment: .leading) {
                ForEach(Array(latestEntries.enumerated()), id: \.element) { index, usage in
                    // In descending order, the "next" usage (if available) represents the previous fueling.
                    let nextUsage: FuelUsage? = (index < latestEntries.count - 1) ? latestEntries[index + 1] : nil
                    FuelUsageRow(usage: usage, nextUsage: nextUsage, colorIndex: index)
                }
                
                // If there are fewer than 3 entries, add skeleton rows to fill the space.
                if fuelUsages.count < 2 {
                    SkeletonFuelUsageRow(colorIndex: fuelUsages.count)
                    SkeletonFuelUsageRow(colorIndex: fuelUsages.count + 1)
                } else if fuelUsages.count < 3 {
                    SkeletonFuelUsageRow(colorIndex: fuelUsages.count)
                }
                
                Spacer()
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

struct FuelUsageRow: View {
    let usage: FuelUsage
    let nextUsage: FuelUsage?
    let colorIndex: Int

    // Compute km per liter for this fueling entry by comparing the current mileage with the previous one.
    // In the descending sorted list, the "next" usage represents the previous fueling.
    var kmPerLiter: Double? {
        if let currentMileage = usage.mileage?.value,
           let previousMileage = nextUsage?.mileage?.value,
           usage.liters > 0 {
            let distance = Double(currentMileage - previousMileage)
            if distance > 0 {
                return distance / usage.liters
            }
        }
        return nil
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(usage.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Text("\(usage.liters, specifier: "%.2f") liters, €\(usage.cost, specifier: "%.2f")")
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                if usage.liters > 0 {
                    Text("€\(usage.cost / usage.liters, specifier: "%.2f")/L")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                if let kmPerLiter = kmPerLiter {
                    Text(String(format: "%.2fkm/l", kmPerLiter))
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

struct EmptyFuelUsageRow: View {
    let colorIndex: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(NSLocalizedString("fuel_usage_empty_title", comment: "No data available"))
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Text(NSLocalizedString("fuel_usage_empty_description", comment: "Tap to add fuel data"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorIndex.isMultiple(of: 2) ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
    }
}

struct FuelUsageGraphView: View {
    let fuelHistory: [FuelUsage]

    var body: some View {
        let dailyMaxFuelUsages = preprocessDailyMaxFuelUsages(fuelHistory: fuelHistory)

        Chart {
            ForEach(dailyMaxFuelUsages, id: \.key) { (date, fuelUsage) in
                LineMark(
                    x: .value("Date", date),
                    y: .value("Liters", fuelUsage.liters)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.green.gradient)

                PointMark(
                    x: .value("Date", date),
                    y: .value("Liters", fuelUsage.liters)
                )
                .foregroundStyle(Color.green)
                .symbolSize(10)

                AreaMark(
                    x: .value("Date", date),
                    yStart: .value("Liters", 0),
                    yEnd: .value("Liters", fuelUsage.liters)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.3), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
        }
        .chartXAxis {
            AxisMarks(values: dailyMaxFuelUsages.map { $0.key }) { value in
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
                    Text("\(Int(value.as(Double.self) ?? 0)) L")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartYAxisLabel(NSLocalizedString("fuel_liters_title", comment: ""), position: .leading)
        .chartXAxisLabel(NSLocalizedString("date_label", comment: ""), position: .bottom)
        .chartLegend(.hidden)
        .padding()
        .frame(minHeight: 250)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 4)
        )
        .cornerRadius(12)
    }

    private func preprocessDailyMaxFuelUsages(fuelHistory: [FuelUsage]) -> [(key: Date, value: FuelUsage)] {
        Dictionary(grouping: fuelHistory, by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.max(by: { $0.liters < $1.liters })! }
            .sorted(by: { $0.key < $1.key })
    }
}

struct FuelUsageTabHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        print("Reducing preference key value: \(value) -> \(next)")
        value = max(value, next)
    }
}

struct SkeletonFuelUsageRow: View {
    let colorIndex: Int
    @State private var isAnimating = false

    var body: some View {
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

// Shimmer Effect Modifier

struct ShimmerEffectModifier: ViewModifier {
    let isAnimating: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.6 : 1.0)
            .overlay(
                GeometryReader { geometry in
                    Color.white
                        .opacity(0.4)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.6), Color.clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                        .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                }
            )
    }
}

extension View {
    func shimmerEffect(isAnimating: Bool) -> some View {
        self.modifier(ShimmerEffectModifier(isAnimating: isAnimating))
    }
}
