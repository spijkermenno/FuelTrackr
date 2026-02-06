//
//  CustomReviewView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/01/2026.
//

import SwiftUI
import ScovilleKit

// Preference key to communicate desired detent size
struct ReviewDetentPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: PresentationDetent = .medium
    static func reduce(value: inout PresentationDetent, nextValue: () -> PresentationDetent) {
        value = nextValue()
    }
}

struct CustomReviewView: View {
    @Binding var isPresented: Bool
    @State private var selectedRating: Int = 0
    @State private var feedbackText: String = ""
    @State private var showFeedbackField: Bool = false
    @State private var isSubmitting: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    // TODO: Update with actual App Store URL when app is published
    // Format: https://apps.apple.com/app/[app-name]/id[app-id]?action=write-review
    private let appStoreURL = "https://apps.apple.com/app/fueltrackr/id6739990000?action=write-review"
    private let minCharacterCount = 10
    private let maxCharacterCount = 300
    private let cooldownDays: Double = 30 // 1 month
    
    private var characterCount: Int {
        feedbackText.count
    }
    
    private var isFeedbackValid: Bool {
        let trimmed = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= minCharacterCount && trimmed.count <= maxCharacterCount
    }
    
    private var canSubmit: Bool {
        if selectedRating >= 4 {
            return true
        }
        return isFeedbackValid && !isSubmitting
    }
    
    private var isOnCooldown: Bool {
        let key = "lastFeedbackSubmissionDate"
        guard let lastSubmission = UserDefaults.standard.object(forKey: key) as? Date else {
            return false
        }
        let daysSince = Date().timeIntervalSince(lastSubmission) / 86400
        return daysSince < cooldownDays
    }
    
    private var cooldownDaysRemaining: Int? {
        let key = "lastFeedbackSubmissionDate"
        guard let lastSubmission = UserDefaults.standard.object(forKey: key) as? Date else {
            return nil
        }
        let daysSince = Date().timeIntervalSince(lastSubmission) / 86400
        guard daysSince < cooldownDays else {
            return nil
        }
        return Int(cooldownDays - daysSince)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("review_title", comment: ""))
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.top, 8)

                        Text(NSLocalizedString("review_subtitle", comment: ""))
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Text(NSLocalizedString("review_description", comment: ""))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 8)
                            .padding(.top, 4)
                    }
                }
                .padding(.top, 20)
                
                // Star Rating
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { rating in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedRating = rating
                                showFeedbackField = rating < 4
                            }
                        } label: {
                            Image(systemName: rating <= selectedRating ? "star.fill" : "star")
                                .font(.system(size: 40))
                                .foregroundColor(rating <= selectedRating ? .yellow : .gray.opacity(0.3))
                                .scaleEffect(rating == selectedRating ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedRating)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(NSLocalizedString("review_star_rating", comment: "").replacingOccurrences(of: "%d", with: "\(rating)"))
                    }
                }
                .padding(.vertical, 8)
                
                // Feedback Field (for < 4 stars)
                if showFeedbackField && selectedRating > 0 && selectedRating < 4 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("review_feedback_prompt", comment: ""))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        
                        TextField(NSLocalizedString("review_feedback_placeholder", comment: ""), text: $feedbackText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isFeedbackValid || feedbackText.isEmpty ? Color(.separator) : Color.red.opacity(0.5),
                                        lineWidth: 1
                                    )
                                    .animation(.easeInOut(duration: 0.2), value: isFeedbackValid)
                            )
                            .lineLimit(3...6)
                            .onChange(of: feedbackText) { oldValue, newValue in
                                // Limit to max character count
                                if newValue.count > maxCharacterCount {
                                    feedbackText = String(newValue.prefix(maxCharacterCount))
                                }
                            }
                        
                        // Character counter and validation message in same row
                        HStack {
                            // Validation message on the left
                            if !feedbackText.isEmpty && !isFeedbackValid {
                                Group {
                                    if characterCount < minCharacterCount {
                                        Text(String(format: NSLocalizedString("review_feedback_min_chars", comment: ""), minCharacterCount))
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.orange)
                                    } else if characterCount > maxCharacterCount {
                                        Text(String(format: NSLocalizedString("review_feedback_max_chars", comment: ""), maxCharacterCount))
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.red)
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .leading)).combined(with: .scale(scale: 0.9)),
                                    removal: .opacity.combined(with: .move(edge: .leading)).combined(with: .scale(scale: 0.9))
                                ))
                            }
                            
                            Spacer()
                            
                            // Character counter on the right
                            Text("\(characterCount)/\(maxCharacterCount)")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(
                                    characterCount < minCharacterCount ? .orange :
                                    characterCount > maxCharacterCount ? .red : .secondary
                                )
                                .contentTransition(.numericText())
                        }
                        .padding(.horizontal, 4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: !feedbackText.isEmpty && !isFeedbackValid)
                    }
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Flexible spacer that adjusts based on feedback field
                if !showFeedbackField {
                    Spacer(minLength: 20)
                }
                
                // Cooldown warning
                if isOnCooldown, let daysRemaining = cooldownDaysRemaining {
                    VStack(spacing: 4) {
                        Text(NSLocalizedString("review_cooldown_recent", comment: ""))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                        Text(String(format: NSLocalizedString("review_cooldown_days", comment: ""), daysRemaining))
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.95)))
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    if selectedRating > 0 {
                        Button {
                            handleRatingSubmission()
                        } label: {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(selectedRating >= 4 ? NSLocalizedString("review_go_to_app_store", comment: "") : NSLocalizedString("review_submit_feedback", comment: ""))
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor,
                                        Color.accentColor.opacity(0.85)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: Color.accentColor.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        }
                        .disabled(!canSubmit || isOnCooldown || isSubmitting)
                        .opacity((!canSubmit || isOnCooldown) ? 0.5 : 1.0)
                        .scaleEffect((!canSubmit || isOnCooldown) ? 0.98 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: canSubmit)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOnCooldown)
                        .accessibilityLabel(selectedRating >= 4 ? NSLocalizedString("review_go_to_app_store", comment: "") : NSLocalizedString("review_submit_feedback", comment: ""))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    // Inline warning for empty feedback (only show when empty, not for character count)
                    if selectedRating > 0 && selectedRating < 4 {
                        if feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(NSLocalizedString("review_feedback_required", comment: ""))
                                .font(.system(.footnote, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 2)
                                .transition(.opacity.combined(with: .move(edge: .bottom)).combined(with: .scale(scale: 0.95)))
                        }
                    }
                    
                    // "Maybe later" button
                    if selectedRating == 0 || selectedRating < 4 {
                        Button {
                            isPresented = false
                        } label: {
                            Text(NSLocalizedString("review_maybe_later", comment: ""))
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .accessibilityLabel(NSLocalizedString("review_maybe_later", comment: ""))
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, showFeedbackField ? 20 : 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isOnCooldown)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedRating)
        }
        .animation(.easeInOut(duration: 0.2), value: showFeedbackField)
        .preference(key: ReviewDetentPreferenceKey.self, value: showFeedbackField ? .fraction(0.80) : .medium)
    }
    
    private func handleRatingSubmission() {
        // Prevent double submission
        guard !isSubmitting else {
            return
        }
        
        // Check cooldown
        guard !isOnCooldown else {
            return
        }
        
        // Validate feedback for ratings < 4
        if selectedRating < 4 {
            let trimmedFeedback = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedFeedback.count >= minCharacterCount && trimmedFeedback.count <= maxCharacterCount else {
                return
            }
        }
        
        isSubmitting = true
        
        let trimmedFeedback = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        let feedback: String? = trimmedFeedback.isEmpty ? nil : trimmedFeedback
        
        // For ratings > 3, send event to ScovilleKit before submitting review
        if selectedRating > 3 {
            Scoville.track(FuelTrackrEvents.positiveReview, parameters: ["rating": String(selectedRating)])
        } else {
            Scoville.track(FuelTrackrEvents.negativeReview, parameters: ["rating": String(selectedRating)])
        }
        
        let currentRating = selectedRating
        let appStoreURLString = appStoreURL
        
        Scoville.submitReview(rating: selectedRating, feedback: feedback) { result in
            switch result {
            case .success(let response):
                // Save submission date for cooldown
                UserDefaults.standard.set(Date(), forKey: "lastFeedbackSubmissionDate")
                
                // Notify ReviewPrompter that cooldown state has changed
                Task { @MainActor in
                    ReviewPrompter.shared.refreshCooldownState()
                }
                
                DispatchQueue.main.async {
                    isSubmitting = false
                    
                    // For ratings > 3, redirect to App Store
                    if currentRating > 3 {
                        if let url = URL(string: appStoreURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    isPresented = false
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    isSubmitting = false
                    
                    // For ratings > 3, still redirect to App Store even if submission failed
                    if currentRating > 3 {
                        if let url = URL(string: appStoreURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    CustomReviewView(isPresented: .constant(true))
}
