//
//  TextFieldSection.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI

struct TextFieldSection: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            TextField(placeholder, text: $text)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .foregroundColor(.primary)
                .keyboardType(.default)
        }
    }
}
