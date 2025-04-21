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
                        // Pass the unit setting to the details view
                        VehicleDetailsView(vehicle: vehicle, isMetric: repository.isUsingMetric())
                            .tag(0)

                        // Check if there is enough mileage data for a graph
                        if vehicle.mileages.count > 1 {
                            // Pass the unit setting to the graph view
                            MileageGraphView(mileageHistory: vehicle.mileages, isMetric: repository.isUsingMetric())
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
                .frame(height: tabHeight)
                .animation(.easeInOut(duration: 0.3), value: tabHeight)

                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 0 ? .orange : .gray)

                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 1 ? .orange : .gray)
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
    let isMetric: Bool  // New parameter to decide whether to convert for display

    var body: some View {
        // Preprocess the data grouped by day (in km)
        let dailyMaxMileages = preprocessDailyMaxMileages(mileageHistory: mileageHistory)
        
        // Convert the mileage values if needed
        let convertedData: [(key: Date, value: Double)] = dailyMaxMileages.map { (date, mileage) in
            let displayValue = isMetric ? Double(mileage.value) : convertKmToMiles(km: Double(mileage.value))
            return (key: date, value: displayValue)
        }
        
        // Calculate bounds for the chart using the converted values
        let lowestMileage = convertedData.map { $0.value }.min() ?? 0
        let highestMileage = convertedData.map { $0.value }.max() ?? 0
        let chartLowerBound = lowestMileage - 10  // adjust padding as needed
        
        Chart {
            ForEach(convertedData, id: \.key) { (date, mileageValue) in
                LineMark(
                    x: .value("Date", date),
                    y: .value("Mileage", mileageValue)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.orange.gradient)

                PointMark(
                    x: .value("Date", date),
                    y: .value("Mileage", mileageValue)
                )
                .foregroundStyle(Color.orange)
                .symbolSize(20)

                AreaMark(
                    x: .value("Date", date),
                    yStart: .value("Mileage", chartLowerBound),
                    yEnd: .value("Mileage", mileageValue)
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
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    // Format label based on the unit system.
                    let displayedValue = value.as(Double.self) ?? 0
                    let unitSuffix = isMetric ? "km" : "mi"
                    Text("\(Int(displayedValue)) \(unitSuffix)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartYScale(domain: (chartLowerBound)...(highestMileage + 10))
        .chartYAxisLabel(
            isMetric ? NSLocalizedString("mileage_title", comment: "Mileage in kilometers") :
                       NSLocalizedString("mileage_title_miles", comment: "Mileage in miles"),
            position: .leading
        )
        .chartXAxisLabel(NSLocalizedString("date_label", comment: ""), position: .bottom)
        .chartLegend(.hidden)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 4)
        )
        .cornerRadius(12)
        .clipped()
    }
    
    // Helper function to process mileage data by day.
    private func preprocessDailyMaxMileages(mileageHistory: [Mileage]) -> [(key: Date, value: Mileage)] {
        Dictionary(grouping: mileageHistory, by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.max(by: { $0.value < $1.value })! }
            .sorted(by: { $0.key < $1.key })
    }
    
    // Conversion function: Convert kilometers to miles.
    private func convertKmToMiles(km: Double) -> Double {
        return km / 1.60934
    }
}
