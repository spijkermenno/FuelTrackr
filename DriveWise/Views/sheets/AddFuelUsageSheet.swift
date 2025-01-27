//
//  AddFuelUsageSheet.swift
//  DriveWise
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

struct AddFuelUsageSheet: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var liters = ""
    @State private var cost = ""
    @State private var mileage = ""
    @State private var errorMessage: String?

    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Title Section
                Text(NSLocalizedString("add_fuel_usage_title", comment: "Add Fuel Usage Title"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                // Form Section
                VStack(spacing: 12) {
                    // Liters Input
                    InputField(
                        title: NSLocalizedString("liters_label", comment: "Label for liters"),
                        placeholder: NSLocalizedString("liters_placeholder", comment: "Label for liters"),
                        text: $liters,
                        keyboardType: .decimalPad
                    )

                    // Cost Input
                    InputField(
                        title: NSLocalizedString("cost_label", comment: "Label for cost"),
                        placeholder: NSLocalizedString("cost_placeholder", comment: "Label for cost"),
                        text: $cost,
                        keyboardType: .decimalPad
                    )

                    // Mileage Input
                    let currentMilage = viewModel.activeVehicle?.mileage ?? 10000
                    InputField(
                        title: NSLocalizedString("mileage_label", comment: "Label for mileage"),
                        placeholder: "\(currentMilage) km",
                        text: $mileage,
                        keyboardType: .numberPad
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Error Section
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                // Buttons Section
                HStack(spacing: 12) {
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
                            guard let liters = parseInput(liters),
                                  let cost = parseInput(cost),
                                  let mileage = Int(mileage) else {
                                return
                            }

                            if viewModel.saveFuelUsage(context: context, liters: liters, cost: cost, mileage: mileage) {
                                dismiss()
                            } else {
                                errorMessage = NSLocalizedString("fuel_usage_saved_error", comment: "Error saving fuel usage")
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
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    // MARK: - Helper Methods

    /// Sanitizes the input based on locale and allows only valid characters.
    private func parseInput(_ input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: decimalSeparator, with: ".")
        return Double(normalized)
    }

    /// Validates all fields for correctness.
    private func validateAllFields() -> Bool {
        guard let litersValue = parseInput(liters), litersValue > 0 else {
            errorMessage = NSLocalizedString("invalid_liters_error", comment: "Error for invalid liters")
            return false
        }

        guard let costValue = parseInput(cost), costValue > 0 else {
            errorMessage = NSLocalizedString("invalid_cost_error", comment: "Error for invalid cost")
            return false
        }

        guard let mileageValue = Int(mileage), mileageValue > 0 else {
            errorMessage = NSLocalizedString("invalid_mileage_error", comment: "Error for invalid mileage")
            return false
        }

        guard let currentMileage = viewModel.activeVehicle?.mileage, mileageValue > currentMileage else {
            errorMessage = NSLocalizedString("invalid_mileage_error", comment: "Mileage must be higher than the current mileage.")
            return false
        }

        errorMessage = nil
        return true
    }
}

// MARK: - Custom InputField View
struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .keyboardType(keyboardType)
        }
    }
}
