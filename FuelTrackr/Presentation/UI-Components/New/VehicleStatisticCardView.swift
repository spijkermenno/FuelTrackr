//
//  VehicleStatisticCardView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/05/2025.
//

import SwiftUI

struct VehicleStatisticCardView: View {
    let uiModel: VehicleStatisticsUiModel
    
    private var isMetric: Bool {
        true // or inject from Environment/ViewModel if needed
    }
    
    private var displayedDistance: String {
        isMetric ? "\(Int(uiModel.distanceDriven).formattedWithSeparator) km" :
        String(format: "%.0f mi", uiModel.distanceDriven / 1.60934)
    }
    
    private var displayedFuelUsed: String {
        isMetric ? String(format: "%.2f L", uiModel.fuelUsed) :
        String(format: "%.2f gal", uiModel.fuelUsed * 0.264172)
    }
    
    private var displayedFuelCost: String {
        String(format: "€%.2f", uiModel.totalCost)
    }
    
    private func title(for period: Period) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "LLLL yyyy" // e.g., "May 2024" or "mei 2024"
        
        switch period {
        case .CurrentMonth:
            let currentDate = Date()
            return dateFormatter.string(from: currentDate).capitalized
            
        case .LastMonth:
            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return dateFormatter.string(from: lastMonth).capitalized
            
        case .YTD:
            return NSLocalizedString("ytd", comment: "Label for Year-to-Date period")
            
        case .AllTime:
            return NSLocalizedString("all_time", comment: "Label for All-Time period")
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text(title(for: uiModel.period))
                    .font(.headline)
            }
            .padding(.top, 12)
            .padding(.horizontal)
            
            HStack(spacing: 6) {
                StatBlock(color: .blue, icon: "car.fill", value: displayedDistance, unit: NSLocalizedString("km_driven", comment: ""))
                StatBlock(color: .orange, icon: "fuelpump.fill", value: displayedFuelUsed, unit: NSLocalizedString("total_fuel_used", comment: ""))
                StatBlock(color: .green, icon: "eurosign.circle.fill", value: displayedFuelCost, unit: NSLocalizedString("total_fuel_cost", comment: ""))
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 0)
    }
}

#Preview {
    let mock = [
        VehicleStatisticsUiModel(period: Period.CurrentMonth, distanceDriven: 1230, fuelUsed: 84.3, totalCost: 123.2),
        VehicleStatisticsUiModel(period: Period.LastMonth, distanceDriven: 2130, fuelUsed: 834.3, totalCost: 1233.2)
    ]
    
    VStack(spacing: 8) {
        ForEach(mock) {
            VehicleStatisticCardView(uiModel: $0)
        }
    }
    .padding()
    .frame(maxHeight: .infinity)
    .background(Color.gray.opacity(0.1))
}

private struct StatBlock: View {
    public let color: Color
    public let icon: String
    public let value: String
    public let unit: String

    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .padding(10)
                .background(color)
                .clipShape(Circle())

            Text(value)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}
