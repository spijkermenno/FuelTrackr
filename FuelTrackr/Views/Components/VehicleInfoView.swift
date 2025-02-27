//
//  VehicleInfoView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/02/2025.
//

import SwiftUI
import Charts

struct VehicleInfoView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @State private var selectedTab = 0
    @State private var tabHeight: CGFloat = 130 // Initial height

    private let repository = SettingsRepository()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("vehicle_details_title", comment: ""))
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 8) {
                TabView(selection: $selectedTab) {
                    if let vehicle = viewModel.activeVehicle {
                        VehicleDetailsView(vehicle: vehicle, isMetric: repository.isUsingMetric())
                            .tag(0)

                        if vehicle.mileages.count > 1 {
                            MileageGraphView(mileageHistory: vehicle.mileages)
                                .tag(1)
                        } else {
                            Text(NSLocalizedString("no_graph_mileage", comment: ""))
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .tag(1)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: tabHeight) // Bind to the state variable
                .animation(.easeInOut(duration: 0.3), value: tabHeight) // Add animation

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
        .onChange(of: selectedTab) { newTab in
            // Animate height change when the selected tab changes
            withAnimation(.easeInOut(duration: 0.3)) {
                tabHeight = newTab == 0 ? 130 : 250
            }
        }
    }
}

struct MileageGraphView: View {
    let mileageHistory: [Mileage]

    var body: some View {
        // Preprocess the mileage data for daily max values
        let dailyMaxMileages = preprocessDailyMaxMileages(mileageHistory: mileageHistory)

        Chart {
            // Line with symbols for each data point
            ForEach(dailyMaxMileages, id: \.key) { (date, mileage) in
                LineMark(
                    x: .value("Date", date),
                    y: .value("Mileage", mileage.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.blue.gradient)

                PointMark(
                    x: .value("Date", date),
                    y: .value("Mileage", mileage.value)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(10)

                // Add area under the line for each point
                AreaMark(
                    x: .value("Date", date),
                    yStart: .value("Mileage", 0),
                    yEnd: .value("Mileage", mileage.value)
                )
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
        }
        .chartXAxis {
            AxisMarks(values: dailyMaxMileages.map { $0.key }) { value in
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
                    Text("\(Int(value.as(Double.self) ?? 0)) km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartYScale(domain: {
            let minMileage = mileageHistory.map { $0.value }.min() ?? 0
            let maxMileage = mileageHistory.map { $0.value }.max() ?? (minMileage + 1000)
            let adjustedMinMileage = max(0, minMileage - 1000)
            return adjustedMinMileage...maxMileage
        }())
        .chartYAxisLabel(NSLocalizedString("mileage_title", comment: ""), position: .leading)
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

    // Helper function to preprocess daily max mileage data
    private func preprocessDailyMaxMileages(mileageHistory: [Mileage]) -> [(key: Date, value: Mileage)] {
        Dictionary(grouping: mileageHistory, by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.max(by: { $0.value < $1.value })! }
            .sorted(by: { $0.key < $1.key })
    }
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
