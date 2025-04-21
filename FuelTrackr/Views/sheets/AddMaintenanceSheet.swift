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
    @State private var keyboardHeight: CGFloat = 0

    // New state variable for "Free / Warranty" checkbox.
    @State private var isFree: Bool = false

    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Title and description with consistent styling.
                    Text(NSLocalizedString("add_maintenance_title", comment: ""))
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.leading)

                    Text(NSLocalizedString("add_maintenance_description", comment: ""))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.leading)

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
                        .disabled(isFree)
                        .opacity(isFree ? 0.6 : 1.0)
                        
                        Toggle(isOn: $isFree) {
                            Text(NSLocalizedString("free_or_warranty", comment: "Label for free or warranty maintenance"))
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                        .padding(.horizontal)
                        .onChange(of: isFree) {
                            if isFree {
                                cost = "0"
                            } else {
                                cost = ""
                            }
                        }

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

                            // Remove the title parameter and let the picker stand alone.
                            DatePicker("", selection: $date, displayedComponents: [.date])
                                .datePickerStyle(WheelDatePickerStyle())
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        // Buttons using the same color scheme.
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
                                    guard let mileageValue = Int(mileage) else { return }
                                    
                                    // When free/warranty is selected, cost is set to 0.
                                    let costValue: Double = isFree ? 0 : (parseInput(cost) ?? 0)
                                    
                                    if viewModel.saveMaintenance(
                                        context: context,
                                        maintenanceType: selectedType,
                                        cost: costValue,
                                        isFree: isFree,
                                        date: date,
                                        mileageValue: mileageValue,
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
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .padding(.horizontal)
                }
                .padding(.bottom, keyboardHeight)
                .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            }
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.bottom)
            .onTapGesture { hideKeyboard() }
            .onAppear { startKeyboardObserver() }
            .onDisappear { stopKeyboardObserver() }
        }
    }

    private func parseInput(_ input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: decimalSeparator, with: ".")
        return Double(normalized)
    }

    private func validateAllFields() -> Bool {
        if !isFree {
            guard let costValue = parseInput(cost), costValue > 0 else {
                errorMessage = NSLocalizedString("invalid_cost_error", comment: "")
                return false
            }
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

    private func startKeyboardObserver() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }

    private func stopKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
