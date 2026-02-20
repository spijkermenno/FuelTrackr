//
//  FuelUsageXMLExporter.swift
//  FuelTrackr
//
//  Exports fuel usages only (date, mileage, amount, cost) for personal use in spreadsheets etc.
//

import Foundation
import Domain

final class FuelUsageXMLExporter {

    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// Exports all fuel usages from the given vehicles to XML.
    /// Only includes: date (datetime), mileage, amount (liters), cost.
    func exportFuelUsages(from vehicles: [Vehicle]) -> String {
        var entries: [(date: Date, mileage: Int, amount: Double, cost: Double)] = []
        for vehicle in vehicles {
            for usage in vehicle.fuelUsages.sorted(by: { $0.date < $1.date }) {
                let mileage = usage.mileage?.value ?? 0
                entries.append((date: usage.date, mileage: mileage, amount: usage.liters, cost: usage.cost))
            }
        }
        entries.sort { $0.date < $1.date }

        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<fuelUsages>\n"
        for entry in entries {
            let dateStr = dateFormatter.string(from: entry.date)
            xml += "  <entry>\n"
            xml += "    <date>\(escapeXML(dateStr))</date>\n"
            xml += "    <mileage>\(entry.mileage)</mileage>\n"
            xml += "    <amount>\(entry.amount)</amount>\n"
            xml += "    <cost>\(entry.cost)</cost>\n"
            xml += "  </entry>\n"
        }
        xml += "</fuelUsages>"
        return xml
    }

    private func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
