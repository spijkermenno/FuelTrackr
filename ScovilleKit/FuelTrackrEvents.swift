//
//  FuelTrackrEvents.swift
//  FuelTrackr
//
//  Created by Menno Spijker
//

import Foundation
import ScovilleKit

public struct FuelTrackrEvents: AnalyticsEventName, Sendable {
    public let rawValue: String
    public init(_ rawValue: String) { self.rawValue = rawValue }
    
    // Fuel
    public static let trackedFuel = FuelTrackrEvents("trackedFuel")
}
