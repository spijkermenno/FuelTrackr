//
//  MaintenanceType.swift
//  DriveWise
//
//  Created by Menno Spijker on 27/01/2025.
//


enum MaintenanceType: String, CaseIterable, Codable {
    case tires = "Tires"
    case distributionBelt = "Distribution Belt"
    case oilChange = "Oil Change"
    case brakes = "Brakes"
    case other = "Other"
}