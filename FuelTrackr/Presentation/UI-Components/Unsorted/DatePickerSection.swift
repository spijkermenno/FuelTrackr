// MARK: - Package: Presentation

//
//  DatePickerSection.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import Domain

public struct DatePickerSection: View {
    public let title: String
    @Binding public var selection: Date

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                DatePicker("", selection: $selection, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)

                Spacer()

                Image(systemName: "calendar")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
}
