//
//  MileageGraphView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 22/04/2025.
//

import SwiftUI
import Charts

struct MileageGraphView: View {
    let mileageHistory: [Mileage]
    let isMetric: Bool
    
    var body: some View {
        let dailyMaxMileages = preprocessDailyMaxMileages(mileageHistory: mileageHistory)

        let convertedData: [(key: Date, value: Double)] = dailyMaxMileages.map { (date, mileage) in
            let displayValue = isMetric ? Double(mileage.value) : convertKmToMiles(km: Double(mileage.value))
            return (key: date, value: displayValue)
        }
        
        let text = if SettingsRepository().isUsingMetric() {
            NSLocalizedString("mileage_history_km", comment: "")
        } else {
            NSLocalizedString("mileage_history_miles", comment: "")
        }

        let lowestMileage = convertedData.map { $0.value }.min() ?? 0
        let highestMileage = convertedData.map { $0.value }.max() ?? 0
        let chartLowerBound = lowestMileage - 10
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("📊")
                Text(text)
                    .font(.headline)
            }
            .padding(.top, 12)
            .padding(.horizontal)
            
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
                        let displayedValue = value.as(Double.self) ?? 0
                        let unit = isMetric ? "km" : "mi"
                        Text("\(Int(displayedValue)) \(unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartYScale(domain: (chartLowerBound)...(highestMileage + 10))
            .chartYAxisLabel(
                isMetric ? NSLocalizedString("mileage_title", comment: "") :
                    NSLocalizedString("mileage_title_miles", comment: ""),
                position: .leading
            )
            .chartXAxisLabel(NSLocalizedString("date_label", comment: ""), position: .bottom)
            .chartLegend(.hidden)
            .frame(height: 200)
            .padding()
        }
    }

    private func preprocessDailyMaxMileages(mileageHistory: [Mileage]) -> [(key: Date, value: Mileage)] {
        Dictionary(grouping: mileageHistory, by: { Calendar.current.startOfDay(for: $0.date) })
            .mapValues { $0.max(by: { $0.value < $1.value })! }
            .sorted(by: { $0.key < $1.key })
    }

    private func convertKmToMiles(km: Double) -> Double {
        km / 1.60934
    }
}
