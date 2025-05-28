//
//  date+extensions.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/05/2025.
//

import Foundation

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Date {
    func relativeDescription(from referenceDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self, to: referenceDate)

        var parts: [String] = []
        if let years = components.year, years > 0 {
            parts.append("\(years) jaar")
        }
        if let months = components.month, months > 0 {
            parts.append("\(months) maanden")
        }
        if parts.isEmpty, let days = components.day {
            parts.append("\(days) dagen")
        }

        return parts.joined(separator: ", ") + " geleden"
    }
}
