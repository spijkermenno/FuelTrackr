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
    public static let failedToLoadProducts = FuelTrackrEvents("failedToLoadProducts")
    public static let IAPFullPremiumBought = FuelTrackrEvents("IAPFullPremiumBought")
    public static let IAPCancelled = FuelTrackrEvents("IAPCancelled")
    public static let IAPFailed = FuelTrackrEvents("IAPFailed")
    
    // Review
    public static let askedForUserReview = FuelTrackrEvents("askedForUserReview")
    public static let reviewPromptSkipped = FuelTrackrEvents("reviewPromptSkipped")
    public static let reviewPromptSkippedCooldown = FuelTrackrEvents("reviewPromptSkippedCooldown")
    public static let positiveReview = FuelTrackrEvents("positiveReview")
    public static let negativeReview = FuelTrackrEvents("negativeReview")
    public static let appSuggestionSubmitted = FuelTrackrEvents("appSuggestionSubmitted")
    public static let reviewButtonClicked = FuelTrackrEvents("reviewButtonClicked")
    public static let suggestionButtonClicked = FuelTrackrEvents("suggestionButtonClicked")
}
