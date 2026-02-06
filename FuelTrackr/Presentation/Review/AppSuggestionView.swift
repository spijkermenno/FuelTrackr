//
//  AppSuggestionView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/01/2026.
//

import SwiftUI
import ScovilleKit

struct AppSuggestionView: View {
    @Binding var isPresented: Bool
    @State private var suggestionText: String = ""
    @State private var isSubmitting: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    private let minCharacterCount = 10
    private let maxCharacterCount = 500
    
    private var characterCount: Int {
        suggestionText.count
    }
    
    private var isSuggestionValid: Bool {
        let trimmed = suggestionText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= minCharacterCount && trimmed.count <= maxCharacterCount
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 8) {
                            Text(NSLocalizedString("suggestion_title", comment: ""))
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                            
                            Text(NSLocalizedString("suggestion_subtitle", comment: ""))
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Suggestion Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("suggestion_field_label", comment: ""))
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        TextField(NSLocalizedString("suggestion_field_placeholder", comment: ""), text: $suggestionText, axis: .vertical)
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
                                        isSuggestionValid || suggestionText.isEmpty ? Color(.separator) : Color.red.opacity(0.5),
                                        lineWidth: 1
                                    )
                            )
                            .lineLimit(5...10)
                            .onChange(of: suggestionText) { oldValue, newValue in
                                // Limit to max character count
                                if newValue.count > maxCharacterCount {
                                    suggestionText = String(newValue.prefix(maxCharacterCount))
                                }
                            }
                        
                        // Character counter
                        HStack {
                            Spacer()
                            Text("\(characterCount)/\(maxCharacterCount)")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(
                                    characterCount < minCharacterCount ? .orange :
                                    characterCount > maxCharacterCount ? .red : .secondary
                                )
                        }
                        .padding(.horizontal, 4)
                        
                        // Validation message
                        if !suggestionText.isEmpty && !isSuggestionValid {
                            if characterCount < minCharacterCount {
                                Text(String(format: NSLocalizedString("suggestion_min_chars", comment: ""), minCharacterCount))
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.orange)
                            } else if characterCount > maxCharacterCount {
                                Text(String(format: NSLocalizedString("suggestion_max_chars", comment: ""), maxCharacterCount))
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                    
                    // Submit Button
                    Button {
                        submitSuggestion()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(NSLocalizedString("suggestion_submit", comment: ""))
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
                    .disabled(!isSuggestionValid || isSubmitting)
                    .opacity(isSuggestionValid ? 1.0 : 0.5)
                    .accessibilityLabel(NSLocalizedString("suggestion_submit", comment: ""))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("close", comment: "")) {
                        isPresented = false
                    }
                    .accessibilityLabel(NSLocalizedString("close", comment: ""))
                }
            }
        }
    }
    
    private func submitSuggestion() {
        guard !isSubmitting else { return }
        guard isSuggestionValid else { return }
        
        isSubmitting = true
        
        let trimmedSuggestion = suggestionText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Track suggestion via ScovilleKit
        Scoville.track(FuelTrackrEvents.appSuggestionSubmitted, parameters: [
            "suggestion": trimmedSuggestion,
            "character_count": String(characterCount)
        ])
        
        // Simulate submission delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            isPresented = false
        }
    }
}

#Preview {
    AppSuggestionView(isPresented: .constant(true))
}
