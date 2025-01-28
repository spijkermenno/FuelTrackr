//
//  AddMaintenanceSheet.swift
//  FuelTrackr
//

import SwiftUI

struct AddMaintenanceSheet: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var selectedType: MaintenanceType = .tires
    @State private var cost = ""
    @State private var notes = ""
    @State private var mileage = ""
    @State private var date = Date()
    @State private var errorMessage: String?

    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    var body: some View {
        NavigationView {
            ScrollView { // Use ScrollView to ensure all content fits on smaller screens
                VStack(spacing: 20) {
                    // Title Section
                    Text(NSLocalizedString("add_maintenance_title", comment: "Add Maintenance Title"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    // Description Section
                    Text(NSLocalizedString("add_maintenance_description", comment: "Description for adding past maintenances"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    // Form Section
                    VStack(spacing: 16) {
                        // Maintenance Type Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("maintenance_type", comment: "Maintenance Type"))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Picker(NSLocalizedString("maintenance_type", comment: "Maintenance Type"), selection: $selectedType) {
                                ForEach(MaintenanceType.allCases, id: \.self) { type in
                                    Text(type.localized.capitalized)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .cornerRadius(8)
                        }

                        // Notes Input (Visible Only for "Other")
                        if selectedType == .other {
                            InputField(
                                title: NSLocalizedString("other_notes", comment: "Other Notes"),
                                placeholder: NSLocalizedString("other_notes_placeholder", comment: "Placeholder for other notes"),
                                text: $notes
                            )
                        }

                        // Cost Input
                        InputField(
                            title: NSLocalizedString("cost_label", comment: "Cost"),
                            placeholder: NSLocalizedString("cost_placeholder", comment: "Placeholder for cost"),
                            text: $cost,
                            keyboardType: .decimalPad
                        )

                        // Mileage Input
                        InputField(
                            title: NSLocalizedString("mileage_label", comment: "Mileage"),
                            placeholder: NSLocalizedString("mileage_placeholder", comment: "Placeholder for mileage"),
                            text: $mileage,
                            keyboardType: .numberPad
                        )

                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("date_label", comment: "Date"))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            DatePicker(
                                NSLocalizedString("select_date", comment: "Select Maintenance Date"),
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .padding()
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                        
                        // Error Section
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        // Buttons Section
                        HStack(spacing: 16) {
                            Button(action: {
                                dismiss()
                            }) {
                                Text(NSLocalizedString("cancel", comment: "Cancel button"))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                if validateAllFields() {
                                    guard let costValue = parseInput(cost),
                                          let mileageValue = Int(mileage) else { return }

                                    if viewModel.saveMaintenance(
                                        context: context,
                                        maintenanceType: selectedType,
                                        cost: costValue,
                                        date: date,
                                        mileage: mileageValue,
                                        notes: selectedType == .other ? notes : nil
                                    ) {
                                        dismiss()
                                    } else {
                                        errorMessage = NSLocalizedString("maintenance_save_error", comment: "Error saving maintenance")
                                    }
                                }
                            }) {
                                Text(NSLocalizedString("save", comment: "Save button"))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom) // Add padding to ensure buttons are not cut off
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    // MARK: - Helper Methods

    private func parseInput(_ input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: decimalSeparator, with: ".")
        return Double(normalized)
    }

    private func validateAllFields() -> Bool {
        guard let costValue = parseInput(cost), costValue > 0 else {
            errorMessage = NSLocalizedString("invalid_cost_error", comment: "Error for invalid cost")
            return false
        }

        guard let mileageValue = Int(mileage), mileageValue > 0 else {
            errorMessage = NSLocalizedString("invalid_mileage_error", comment: "Error for invalid mileage")
            return false
        }

        if selectedType == .other && notes.isEmpty {
            errorMessage = NSLocalizedString("invalid_notes_error", comment: "Error for empty notes")
            return false
        }

        errorMessage = nil
        return true
    }
}
