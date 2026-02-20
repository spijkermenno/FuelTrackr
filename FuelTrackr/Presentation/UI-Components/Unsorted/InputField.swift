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
        let colors = Theme.colors(for: colorScheme)
        
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(placeholderColor(colors: colors))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }
                TextField("", text: $text)
                    .padding()
                    .keyboardType(keyboardType)
                    .foregroundColor(.primary)
                    .focused($isFocused)
            }
            .background(backgroundColor)
            .cornerRadius(8)
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
    
    private func placeholderColor(colors: ColorsProtocol) -> Color {
        colorScheme == .dark ? colors.onSurface : Color(.placeholderText)
    }
    
    private var backgroundColor: Color {
        let colors = Theme.colors(for: colorScheme)
        if colorScheme == .dark {
            return colors.surface
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
            return colorScheme == .dark ? colors.onSurface.opacity(0.35) : Color(.separator).opacity(0.3)
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
