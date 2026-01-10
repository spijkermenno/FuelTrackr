//
//  MonthlyFuelSummaryUiModel.swift
//  FuelTrackr
//
//  Created for redesigned ActiveVehicleView
//

import Foundation

public enum MonthlySummaryPeriod {
    case month(month: Int, year: Int)
    case yearToDate(year: Int)
    case year(year: Int)
}

public struct MonthlyFuelSummaryUiModel: Identifiable {
    public let id: UUID
    public let period: MonthlySummaryPeriod
    public let totalDistance: Double // in km
    public let averagePricePerLiter: Double // calculated from fuel entries
    public let totalFuelVolume: Double // in liters
    public let totalCost: Double
    
    public init(
        id: UUID = UUID(),
        period: MonthlySummaryPeriod,
        totalDistance: Double,
        averagePricePerLiter: Double,
        totalFuelVolume: Double,
        totalCost: Double
    ) {
        self.id = id
        self.period = period
        self.totalDistance = totalDistance
        self.averagePricePerLiter = averagePricePerLiter
        self.totalFuelVolume = totalFuelVolume
        self.totalCost = totalCost
    }
    
    // Convenience initializer for backward compatibility
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
        self.period = .month(month: month, year: year)
        self.totalDistance = totalDistance
        self.averagePricePerLiter = averagePricePerLiter
        self.totalFuelVolume = totalFuelVolume
        self.totalCost = totalCost
    }
    
    public var monthYearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        switch period {
        case .month(let month, let year):
            dateFormatter.dateFormat = "MMMM yyyy"
            let calendar = Calendar.current
            if let date = calendar.date(from: DateComponents(year: year, month: month)) {
                return dateFormatter.string(from: date)
            }
            return "\(month)/\(year)"
            
        case .yearToDate(let year):
            return NSLocalizedString("ytd", comment: "Year to Date") + " \(year)"
            
        case .year(let year):
            return "\(year)"
        }
    }
    
    // Backward compatibility properties
    public var month: Int {
        if case .month(let month, _) = period {
            return month
        }
        return 0
    }
    
    public var year: Int {
        switch period {
        case .month(_, let year):
            return year
        case .yearToDate(let year):
            return year
        case .year(let year):
            return year
        }
    }
}
