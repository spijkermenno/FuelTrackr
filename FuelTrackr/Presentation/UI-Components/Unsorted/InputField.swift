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

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .keyboardType(keyboardType)
                .foregroundColor(.primary)
                .focused($isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            borderColor,
                            lineWidth: isFocused ? 2 : (hasError || hasWarning ? 1.5 : 0)
                        )
                )
                .accessibilityLabel(title)
                .accessibilityHint(placeholder)
                .accessibilityValue(text.isEmpty ? placeholder : text)
        }
    }
    
    private var borderColor: Color {
        if hasError {
            return .red
        } else if hasWarning {
            return .orange
        } else if isFocused {
            return .blue
        } else {
            return .clear
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
