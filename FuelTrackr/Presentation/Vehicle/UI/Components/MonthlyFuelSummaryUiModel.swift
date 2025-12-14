//
//  MonthlyFuelSummaryUiModel.swift
//  FuelTrackr
//
//  Created for redesigned ActiveVehicleView
//

import Foundation

public struct MonthlyFuelSummaryUiModel: Identifiable {
    public let id: UUID
    public let month: Int
    public let year: Int
    public let totalDistance: Double // in km
    public let averagePricePerLiter: Double // calculated from fuel entries
    public let totalFuelVolume: Double // in liters
    public let totalCost: Double
    
    public init(
        id: UUID = UUID(),
        month: Int,
        year: Int,
        totalDistance: Double,
        averagePricePerLiter: Double,
        totalFuelVolume: Double,
        totalCost: Double
    ) {
        self.id = id
        self.month = month
        self.year = year
        self.totalDistance = totalDistance
        self.averagePricePerLiter = averagePricePerLiter
        self.totalFuelVolume = totalFuelVolume
        self.totalCost = totalCost
    }
    
    public var monthYearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let calendar = Calendar.current
        if let date = calendar.date(from: DateComponents(year: year, month: month)) {
            return dateFormatter.string(from: date)
        }
        return "\(month)/\(year)"
    }
}
