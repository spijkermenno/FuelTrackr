//
//  MaintenanceType.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI

enum MaintenanceType: String, CaseIterable, Codable {
    case tires = "Tires"
    case distributionBelt = "Distribution Belt"
    case oilChange = "Oil Change"
    case brakes = "Brakes"
    case other = "Other"

    var localized: String {
        switch self {
        case .tires:
            return NSLocalizedString("tires", comment: "Tires maintenance type")
        case .distributionBelt:
            return NSLocalizedString("distribution_belt", comment: "Distribution Belt maintenance type")
        case .oilChange:
            return NSLocalizedString("oil_change", comment: "Oil Change maintenance type")
        case .brakes:
            return NSLocalizedString("brakes", comment: "Brakes maintenance type")
        case .other:
            return NSLocalizedString("other", comment: "Other maintenance type")
        }
    }
}
