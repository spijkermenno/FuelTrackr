//
//  ReviewPrompter.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/01/2026.
//

import StoreKit
import SwiftUI
import ScovilleKit
import FirebaseAnalytics

enum ReviewTriggerReason: String {
    case fuelTracked
    case maintenanceAdded
    case purchaseDone
    case appUsage
    case debug
}

@MainActor
final class ReviewPrompter: ObservableObject {
    static let shared = ReviewPrompter()
    private init() {}
    
    /// Minimum number of days between review prompts (for any reason)
    private let cooldownDays: Double = 45
    
    /// Cooldown period for feedback submissions (1 month)
    private let feedbackCooldownDays: Double = 30
    private let feedbackCooldownKey = "lastFeedbackSubmissionDate"
    
    // State for showing custom review view
    @Published var showCustomReview = false
    
    /// Checks if feedback submission is on cooldown
    var isFeedbackOnCooldown: Bool {
        guard let lastSubmission = UserDefaults.standard.object(forKey: feedbackCooldownKey) as? Date else {
            return false
        }
        let daysSince = Date().timeIntervalSince(lastSubmission) / 86400
        return daysSince < feedbackCooldownDays
    }
    
    /// Refreshes the cooldown state and notifies observers
    func refreshCooldownState() {
        objectWillChange.send()
    }
    
    func maybeRequestReview(reason: ReviewTriggerReason) {
        // Check if feedback submission is on cooldown - don't show sheet if user recently submitted feedback
        if isFeedbackOnCooldown {
            let params: [String: Any] = ["reason": reason.rawValue]
            Scoville.track(FuelTrackrEvents.reviewPromptSkippedCooldown, parameters: params)
            Analytics.logEvent(FuelTrackrEvents.reviewPromptSkippedCooldown.rawValue, parameters: params)
            return
        }
        
        let key = "lastReviewPromptDate"
        let now = Date()
        
        if reason != .debug {
            // Check last prompt date (global cooldown)
            if let lastPrompt = UserDefaults.standard.object(forKey: key) as? Date {
                let daysSince = now.timeIntervalSince(lastPrompt) / 86400
                guard daysSince >= cooldownDays else {
                    let params: [String: Any] = [
                        "reason": reason.rawValue,
                        "days_since": String(Int(daysSince))
                    ]
                    Scoville.track(FuelTrackrEvents.reviewPromptSkipped, parameters: params)
                    Analytics.logEvent(FuelTrackrEvents.reviewPromptSkipped.rawValue, parameters: params)
                    return
                }
            }
            
            // Avoid spamming same reason too often
            let reasonKey = "didAskReview_\(reason.rawValue)"
            if UserDefaults.standard.bool(forKey: reasonKey) {
                return
            }
            UserDefaults.standard.set(true, forKey: reasonKey)
        }
        
        // Show custom review view instead of system prompt
        showCustomReview = true
        
        if reason != .debug {
            // Save timestamp + track
            UserDefaults.standard.set(now, forKey: key)
            Scoville.track(FuelTrackrEvents.askedForUserReview)
            Analytics.logEvent(FuelTrackrEvents.askedForUserReview.rawValue, parameters: nil)
        }
    }
    
    func handleFuelTracked(trackCount: Int) {
        // Show review prompt at milestones: 10, 25, 50, then every 50
        guard trackCount >= 10 else { return }
        
        let milestones: Set<Int> = [10, 25, 50]
        let isMilestone = milestones.contains(trackCount) || ((trackCount > 50) && ((trackCount - 50) % 50 == 0))
        guard isMilestone else { return }
        
        // Small delay to avoid racing with UI transitions
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            ReviewPrompter.shared.maybeRequestReview(reason: .fuelTracked)
        }
    }
}
