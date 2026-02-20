//
//  FuelUsageCSVExporter.swift
//  FuelTrackr
//
//  Exports fuel usages only (date, mileage, amount, cost) for spreadsheets.
//

import Foundation
import Domain

final class FuelUsageCSVExporter {

    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// Exports all fuel usages from the given vehicles to CSV.
    /// Columns: date, mileage, amount, cost.
    func exportFuelUsages(from vehicles: [Vehicle]) -> String {
        var entries: [(date: Date, mileage: Int, amount: Double, cost: Double)] = []
        for vehicle in vehicles {
            for usage in vehicle.fuelUsages.sorted(by: { $0.date < $1.date }) {
                let mileage = usage.mileage?.value ?? 0
                entries.append((date: usage.date, mileage: mileage, amount: usage.liters, cost: usage.cost))
            }
        }
        entries.sort { $0.date < $1.date }

        var csv = "date,mileage,amount,cost\n"
        for entry in entries {
            let dateStr = dateFormatter.string(from: entry.date)
            csv += "\(escapeCSV(dateStr)),\(entry.mileage),\(entry.amount),\(entry.cost)\n"
        }
        return csv
    }

    private func escapeCSV(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }
}
