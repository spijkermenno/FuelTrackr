// MARK: - Package: Presentation

//
//  MaintenanceIntervalRow.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 28/01/2025.
//

import SwiftUI
import Domain

public struct MaintenanceIntervalRow: View {
    public let title: String
    @Binding public var value: Int
    public let unit: String
    public let onValueChange: (Int) -> Void

    public var body: some View {
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

//public struct MaintenanceIntervalRow_Previews: PreviewProvider {
//    public static var previews: some View {
//        Group {
//            MaintenanceIntervalRow(
//                title: "Oil Change",
//                value: .constant(15000),
//                unit: "km",
//                onValueChange: { _ in }
//            )
//            .previewLayout(.sizeThatFits)
//            .padding()
//            .previewDisplayName("Light Mode")
//
//            MaintenanceIntervalRow(
//                title: "Brake Check",
//                value: .constant(20000),
//                unit: "km",
//                onValueChange: { _ in }
//            )
//            .previewLayout(.sizeThatFits)
//            .padding()
//            .background(Color.black)
//            .environment(\.colorScheme, .dark)
//            .previewDisplayName("Dark Mode")
//        }
//    }
//}
