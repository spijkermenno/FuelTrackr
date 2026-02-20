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
    public static let IAPRestored = FuelTrackrEvents("IAPRestored")
    
    // Review
    public static let askedForUserReview = FuelTrackrEvents("askedForUserReview")
    public static let reviewPromptSkipped = FuelTrackrEvents("reviewPromptSkipped")
    public static let reviewPromptSkippedCooldown = FuelTrackrEvents("reviewPromptSkippedCooldown")
    public static let positiveReview = FuelTrackrEvents("positiveReview")
    public static let negativeReview = FuelTrackrEvents("negativeReview")
    public static let appSuggestionSubmitted = FuelTrackrEvents("appSuggestionSubmitted")
    public static let reviewButtonClicked = FuelTrackrEvents("reviewButtonClicked")
    public static let suggestionButtonClicked = FuelTrackrEvents("suggestionButtonClicked")
    
    // Vehicle
    public static let vehicleCreated = FuelTrackrEvents("vehicleCreated")
    public static let vehicleEdited = FuelTrackrEvents("vehicleEdited")
    public static let vehicleDeleted = FuelTrackrEvents("vehicleDeleted")
    
    // Maintenance
    public static let maintenanceTracked = FuelTrackrEvents("maintenanceTracked")
    public static let maintenanceDeleted = FuelTrackrEvents("maintenanceDeleted")
    
    // Paywall
    public static let paywallShown = FuelTrackrEvents("paywallShown")
    public static let paywallDismissed = FuelTrackrEvents("paywallDismissed")
    
    // Settings
    public static let unitPreferenceChanged = FuelTrackrEvents("unitPreferenceChanged")
    
    // Onboarding
    public static let onboardingStarted = FuelTrackrEvents("onboardingStarted")
    public static let onboardingCompleted = FuelTrackrEvents("onboardingCompleted")
    
    // App Lifecycle
    public static let appStarted = FuelTrackrEvents("appStarted")
    
    // Feature Usage
    public static let fuelDetailsViewed = FuelTrackrEvents("fuelDetailsViewed")
    public static let maintenanceHistoryViewed = FuelTrackrEvents("maintenanceHistoryViewed")
    public static let fuelUsageEdited = FuelTrackrEvents("fuelUsageEdited")
    public static let statisticsViewed = FuelTrackrEvents("statisticsViewed")
}
