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
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            TextField("", value: $value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .padding(8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(6)
                .foregroundColor(.primary)
                .onChange(of: value, perform: onValueChange)

            Text(unit)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}
