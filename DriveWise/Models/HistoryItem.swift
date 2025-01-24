//
//  HistoryItem.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftData
import Foundation

@Model
class HistoryItem {
    var type: ActionType
    var dateTime: Date
    var details: String?
    var cost: Double?
    var mileage: Int?
    @Relationship var vehicle: Vehicle // Relatie naar Vehicle
    
    init(type: ActionType, dateTime: Date, details: String? = nil, cost: Double? = nil, mileage: Int? = nil, vehicle: Vehicle) {
        self.type = type
        self.dateTime = dateTime
        self.details = details
        self.cost = cost
        self.mileage = mileage
        self.vehicle = vehicle
    }
}

enum ActionType: String, Codable {
    case refueling
    case maintenance
}
