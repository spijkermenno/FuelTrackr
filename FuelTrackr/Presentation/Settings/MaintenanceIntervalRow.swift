//
//  MaintenanceIntervalRow.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/01/2025.
//

import SwiftUI

struct MaintenanceIntervalRow: View {
    let title: String
    @Binding var value: Int
    let unit: String
    let onValueChange: (Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            TextField("", value: $value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .padding(8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .foregroundColor(.primary)
                .onChange(of: value) { newValue in
                    onValueChange(newValue)
                }

            Text(unit)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

struct MaintenanceIntervalRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MaintenanceIntervalRow(
                title: "Oil Change",
                value: .constant(15000),
                unit: "km",
                onValueChange: { _ in }
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Light Mode")

            MaintenanceIntervalRow(
                title: "Brake Check",
                value: .constant(20000),
                unit: "km",
                onValueChange: { _ in }
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.black)
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
