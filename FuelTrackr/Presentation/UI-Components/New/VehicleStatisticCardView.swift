//
//  VehicleStatisticCardView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/05/2025.
//

import SwiftUI
import Domain

struct VehicleStatisticCardView: View {
    let uiModel: VehicleStatisticsUiModel
    let fuelType: FuelType?
    let isUsingMetric: Bool
    
    init(uiModel: VehicleStatisticsUiModel, fuelType: FuelType? = nil, isUsingMetric: Bool = true) {
        self.uiModel = uiModel
        self.fuelType = fuelType
        self.isUsingMetric = isUsingMetric
    }
    
    private var displayedDistance: String {
        if isUsingMetric {
            return "\(Int(uiModel.distanceDriven).formattedWithSeparator) \(NSLocalizedString("unit_km", comment: ""))"
        } else {
            let miles = uiModel.distanceDriven / 1.60934
            return String(format: "%.0f %@", miles, NSLocalizedString("unit_mi", comment: ""))
        }
    }
    
    private var displayedFuelUsed: String {
        let fuelTypeToUse = fuelType ?? .liquid
        return fuelTypeToUse.formatFuelAmount(uiModel.fuelUsed, isUsingMetric: isUsingMetric)
    }
    
    private var displayedFuelCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: uiModel.totalCost)) ?? String(format: "%.2f", uiModel.totalCost)
    }
    
    private func title(for period: VehicleStatisticsPeriod) -> String {
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
            
        case .ProjectedYear:                            
            return NSLocalizedString("projected_year", comment: "Label for Projected-Year period")
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(25)
    }
}

#Preview {
    let mock = [
        VehicleStatisticsUiModel(period: VehicleStatisticsPeriod.CurrentMonth, distanceDriven: 1230, fuelUsed: 84.3, totalCost: 123.2),
        VehicleStatisticsUiModel(period: VehicleStatisticsPeriod.LastMonth, distanceDriven: 2130, fuelUsed: 834.3, totalCost: 1233.2)
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
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(15)
    }
}
