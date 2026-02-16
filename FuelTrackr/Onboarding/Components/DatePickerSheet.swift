//
//  DatePickerSheet.swift
//  FuelTrackr
//
//  Date picker sheet component for onboarding flow
//

import SwiftUI

public struct DatePickerSheet: View {
    let title: String
    @Binding var selection: Date
    @Binding var isPresented: Bool
    var displayedComponents: DatePickerComponents = [.date]
    
    public init(
        title: String,
        selection: Binding<Date>,
        isPresented: Binding<Bool>,
        displayedComponents: DatePickerComponents = [.date]
    ) {
        self.title = title
        self._selection = selection
        self._isPresented = isPresented
        self.displayedComponents = displayedComponents
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $selection,
                    displayedComponents: displayedComponents
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "Done")) {
                        isPresented = false
                    }
                }
            }
        }
    }
}
