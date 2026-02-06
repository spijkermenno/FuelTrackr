//
//  DateInputField.swift
//  FuelTrackr
//
//  Date input field component for onboarding flow
//

import SwiftUI

public struct DateInputField: View {
    let title: String
    @Binding var date: Date
    let placeholder: String
    var displayedComponents: DatePickerComponents = [.date]
    
    @State private var isExpanded: Bool = false
    
    private var isDateUnselected: Bool {
        // Check if date is today (default/unselected state)
        Calendar.current.isDateInToday(date)
    }
    
    public init(
        title: String,
        date: Binding<Date>,
        placeholder: String,
        displayedComponents: DatePickerComponents = [.date]
    ) {
        self.title = title
        self._date = date
        self.placeholder = placeholder
        self.displayedComponents = displayedComponents
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(OnboardingColors.primaryBlue)
            
            DatePicker(
                "",
                selection: $date,
                displayedComponents: displayedComponents
            )
            .datePickerStyle(.automatic)
            .labelsHidden()
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? UIColor(OnboardingColors.darkGray)
                : UIColor(OnboardingColors.white)
            }))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(OnboardingColors.primaryBlue, lineWidth: 2)
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
}
