//
//  DatePickerSection.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI

struct DatePickerSection: View {
    let title: String
    @Binding var selection: Date

    var body: some View {
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
