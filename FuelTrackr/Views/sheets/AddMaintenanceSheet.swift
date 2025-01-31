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
            ScrollView {
                VStack(spacing: 20) {
                    Text(NSLocalizedString("add_maintenance_title", comment: ""))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    Text(NSLocalizedString("add_maintenance_description", comment: ""))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("maintenance_type", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Picker(NSLocalizedString("maintenance_type", comment: ""), selection: $selectedType) {
                                ForEach(MaintenanceType.allCases, id: \.self) { type in
                                    Text(type.localized.capitalized)
                                        .tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        if selectedType == .other {
                            InputField(
                                title: NSLocalizedString("other_notes", comment: ""),
                                placeholder: NSLocalizedString("other_notes_placeholder", comment: ""),
                                text: $notes
                            )
                        }

                        InputField(
                            title: NSLocalizedString("cost_label", comment: ""),
                            placeholder: NSLocalizedString("cost_placeholder", comment: ""),
                            text: $cost,
                            keyboardType: .decimalPad
                        )

                        InputField(
                            title: NSLocalizedString("mileage_label", comment: ""),
                            placeholder: NSLocalizedString("mileage_placeholder", comment: ""),
                            text: $mileage,
                            keyboardType: .numberPad
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("date_label", comment: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            DatePicker(
                                NSLocalizedString("select_date", comment: ""),
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        HStack(spacing: 16) {
                            Button(action: { dismiss() }) {
                                Text(NSLocalizedString("cancel", comment: ""))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
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
                                        errorMessage = NSLocalizedString("maintenance_save_error", comment: "")
                                    }
                                }
                            }) {
                                Text(NSLocalizedString("save", comment: ""))
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
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    private func parseInput(_ input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: decimalSeparator, with: ".")
        return Double(normalized)
    }

    private func validateAllFields() -> Bool {
        guard let costValue = parseInput(cost), costValue > 0 else {
            errorMessage = NSLocalizedString("invalid_cost_error", comment: "")
            return false
        }

        guard let mileageValue = Int(mileage), mileageValue > 0 else {
            errorMessage = NSLocalizedString("invalid_mileage_error", comment: "")
            return false
        }

        if selectedType == .other && notes.isEmpty {
            errorMessage = NSLocalizedString("invalid_notes_error", comment: "")
            return false
        }

        errorMessage = nil
        return true
    }
}
