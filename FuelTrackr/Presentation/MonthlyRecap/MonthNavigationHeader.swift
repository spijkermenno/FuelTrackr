// MARK: - Package: Presentation
//
//  MonthNavigationHeader.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 29/04/2025.
//

import SwiftUI

public struct MonthNavigationHeader: View {
    @Binding public var selectedMonth: Int
    @Binding public var selectedYear: Int

    public let calendar = Calendar.current
    public let months: [String]

    public init(selectedMonth: Binding<Int>, selectedYear: Binding<Int>) {
        self._selectedMonth = selectedMonth
        self._selectedYear = selectedYear
        self.months = calendar.monthSymbols
    }

    public var body: some View {
        HStack {
            Button(action: goToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.orange)
            }

            Spacer()

            Text(formattedMonth)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Button(action: goToNextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
    }

    public var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL yyyy"
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        let date = calendar.date(from: components) ?? Date()
        let formatted = formatter.string(from: date)
        return formatted.prefix(1).capitalized + formatted.dropFirst()
    }

    public func goToPreviousMonth() {
        selectedMonth -= 1
        if selectedMonth < 1 {
            selectedMonth = 12
            selectedYear -= 1
        }
    }

    public func goToNextMonth() {
        selectedMonth += 1
        if selectedMonth > 12 {
            selectedMonth = 1
            selectedYear += 1
        }
    }
}
