// MARK: - Package: Presentation

//
//  InputField.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/01/2025.
//

import SwiftUI
import Domain

public struct InputField: View {
    public let title: String
    public let placeholder: String
    @Binding public var text: String
    public var keyboardType: UIKeyboardType = .default
    public var hasError: Bool = false
    public var hasWarning: Bool = false
    
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)

            TextField(placeholder, text: $text)
                .padding()
                .background(backgroundColor)
                .cornerRadius(8)
                .keyboardType(keyboardType)
                .foregroundColor(.primary)
                .focused($isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            borderColor,
                            lineWidth: borderWidth
                        )
                )
                .accessibilityLabel(title)
                .accessibilityHint(placeholder)
                .accessibilityValue(text.isEmpty ? placeholder : text)
        }
    }
    
    private var backgroundColor: Color {
        // Use systemBackground with higher opacity for better visibility with glass effects
        // This ensures the input field stands out clearly while maintaining HIG compliance
        if colorScheme == .dark {
            return Color(.systemGray6).opacity(0.9)
        } else {
            return Color(.systemBackground).opacity(0.95)
        }
    }
    
    private var borderColor: Color {
        let colors = Theme.colors(for: colorScheme)
        
        if hasError {
            return colors.error
        } else if hasWarning {
            return .orange
        } else if isFocused {
            return colors.primary
        } else {
            // Subtle border for better visibility with glass effects
            return Color(.separator).opacity(colorScheme == .dark ? 0.5 : 0.3)
        }
    }
    
    private var borderWidth: CGFloat {
        if hasError || hasWarning {
            return 1.5
        } else if isFocused {
            return 2.0
        } else {
            return 0.5 // Subtle border when not focused
        }
    }
    
    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        hasError: Bool = false,
        hasWarning: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.hasError = hasError
        self.hasWarning = hasWarning
    }
}
