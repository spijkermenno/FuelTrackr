//
//  InputField.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/01/2025.
//

import SwiftUI

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
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
