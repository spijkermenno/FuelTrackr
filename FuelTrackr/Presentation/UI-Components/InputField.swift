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

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)

            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .keyboardType(keyboardType)
                .foregroundColor(.primary)
        }
    }
}
