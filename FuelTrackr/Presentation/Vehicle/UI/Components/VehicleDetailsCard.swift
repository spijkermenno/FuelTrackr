//
//  VehicleDetailsCard.swift
//  FuelTrackr
//
//  Card displaying vehicle details: license plate, odometer, purchase date, production date
//

import SwiftUI

public struct VehicleDetailsCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let licensePlate: String
    let currentMileage: Int
    let purchaseDate: Date
    let productionDate: Date
    let isUsingMetric: Bool
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    private var timeSincePurchase: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: purchaseDate, relativeTo: Date())
    }
    
    private var timeSinceProduction: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: productionDate, relativeTo: Date())
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                // License plate at top right
                HStack {
                    Spacer()
                    Text(licensePlate)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(colors.onBackground)
                }
                
                // Three metric rows
                MetricRowView(
                    label: NSLocalizedString("mileage", comment: "Mileage"),
                    value: formatMileage(currentMileage),
                    timeAgo: nil
                )
                
                MetricRowView(
                    label: NSLocalizedString("owned", comment: "Owned"),
                    value: timeSincePurchase,
                    timeAgo: nil
                )
                
                MetricRowView(
                    label: NSLocalizedString("age", comment: "Age"),
                    value: timeSinceProduction,
                    timeAgo: nil
                )
            }
            .padding()
            .frame(height: 190)
            .frame(maxWidth: .infinity)
            .background(colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 31))
            .overlay(
                RoundedRectangle(cornerRadius: 31)
                    .stroke(colors.border, lineWidth: 1)
            )
            .frame(width: geometry.size.width)
        }
    }
    
    private func formatMileage(_ mileage: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        
        if isUsingMetric {
            if let formatted = formatter.string(from: NSNumber(value: mileage)) {
                return "\(formatted) km"
            }
            return String(format: "%d km", mileage)
        } else {
            let miles = Int(Double(mileage) * 0.621371)
            if let formatted = formatter.string(from: NSNumber(value: miles)) {
                return "\(formatted) mi"
            }
            return String(format: "%d mi", miles)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM yyyy" // e.g., "1 januari 2025"
        return formatter.string(from: date)
    }
}

// MARK: - MetricRowView

private struct MetricRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let label: String
    let value: String
    let timeAgo: String?
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(colors.onSurface)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(colors.onBackground)
                
                if let timeAgo = timeAgo {
                    Text(timeAgo)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(colors.primary)
                }
            }
        }
    }
}
