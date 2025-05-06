// MARK: - Package: Presentation

//
//  MileageGraphView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Charts
import Domain

public struct MileageGraphView: View {
    public let mileageHistory: [Mileage]
    public let isMetric: Bool

    public var body: some View {
        let dailyMaxMileages = preprocessDailyMaxMileages(mileageHistory: mileageHistory)
        let convertedData = dailyMaxMileages.map { (date, mileage) -> (key: Date, value: Double) in
            let value = isMetric ? Double(mileage.value) : convertKmToMiles(km: Double(mileage.value))
            return (key: date, value: value)
        }

        let text = isMetric
            ? NSLocalizedString("mileage_history_km", comment: "Mileage history in kilometers")
            : NSLocalizedString("mileage_history_miles", comment: "Mileage history in miles")

        let lowestMileage = convertedData.map { $0.value }.min() ?? 0
        let highestMileage = convertedData.map { $0.value }.max() ?? 0
        let chartLowerBound = max(lowestMileage - 10, 0)

        VStack(alignment: .leading, spacing: 8) {
            header(text: text)

            Chart {
                ForEach(convertedData, id: \.key) { date, mileageValue in
                    LineMark(
                        x: .value(NSLocalizedString("date_label", comment: ""), date),
                        y: .value(NSLocalizedString("mileage_title", comment: ""), mileageValue)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.orange.gradient)

                    PointMark(
                        x: .value(NSLocalizedString("date_label", comment: ""), date),
                        y: .value(NSLocalizedString("mileage_title", comment: ""), mileageValue)
                    )
                    .foregroundStyle(Color.orange)
                    .symbolSize(20)

                    AreaMark(
                        x: .value(NSLocalizedString("date_label", comment: ""), date),
                        yStart: .value("MinMileage", chartLowerBound),
                        yEnd: .value(NSLocalizedString("mileage_title", comment: ""), mileageValue)
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
                        if let val = value.as(Double.self) {
                            Text("\(Int(val)) \(isMetric ? "km" : "mi")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .chartYScale(domain: chartLowerBound...(highestMileage + 10))
            .chartLegend(.hidden)
            .frame(height: 200)
            .padding()
        }
    }

    private func header(text: String) -> some View {
        HStack(spacing: 8) {
            Text("📊")
            Text(text)
                .font(.headline)
        }
        .padding(.top, 12)
        .padding(.horizontal)
    }

    private func preprocessDailyMaxMileages(mileageHistory: [Mileage]) -> [(key: Date, value: Mileage)] {
        Dictionary(grouping: mileageHistory, by: { Calendar.current.startOfDay(for: $0.date) })
            .compactMapValues { $0.max(by: { $0.value < $1.value }) }
            .sorted(by: { $0.key < $1.key })
    }

    private func convertKmToMiles(km: Double) -> Double {
        km / 1.60934
    }
}
