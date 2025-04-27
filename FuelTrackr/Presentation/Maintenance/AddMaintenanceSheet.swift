//
//  AddMaintenanceSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI

struct AddMaintenanceSheet: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedType: MaintenanceType = .tires
    @State private var cost = ""
    @State private var notes = ""
    @State private var mileage = ""
    @State private var date = Date()
    @State private var isFree = false
    @State private var errorMessage: String?
    @State private var keyboardHeight: CGFloat = 0

    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    headerSection
                    formSection
                    buttonSection
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

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("add_maintenance_title", comment: ""))
                .font(.title2.weight(.bold))
                .padding(.top, 30)
            Text(NSLocalizedString("add_maintenance_description", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 32)
        .multilineTextAlignment(.leading)
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            maintenanceTypePicker

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
            .opacity(isFree ? 0.6 : 1)

            Toggle(isOn: $isFree) {
                Text(NSLocalizedString("free_or_warranty", comment: ""))
                    .font(.body)
            }
            .toggleStyle(SwitchToggleStyle(tint: .orange))
            .padding(.horizontal)
            .onChange(of: isFree) {
                if isFree { cost = "0" } else { cost = "" }
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
        }
        .padding()
    }

    private var maintenanceTypePicker: some View {
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
    }

    private var buttonSection: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Text(NSLocalizedString("cancel", comment: ""))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
            }

            Button(action: saveMaintenance) {
                Text(NSLocalizedString("save", comment: ""))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding([.horizontal, .bottom])
    }

    // MARK: - Actions

    private func saveMaintenance() {
        guard validateAllFields() else { return }

        guard let mileageValue = Int(mileage) else { return }
        let costValue: Double = isFree ? 0 : (parseInput(cost) ?? 0)

        let mileage = Mileage(
            value: mileageValue,
            date: date
        )

        let maintenance = Maintenance(
            type: selectedType,
            cost: costValue,
            isFree: isFree,
            date: date,
            mileage: mileage,
            notes: selectedType == .other ? notes : nil
        )

        viewModel.saveMaintenance(maintenance: maintenance)
        dismiss()
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

    private func parseInput(_ input: String) -> Double? {
        let normalized = input.replacingOccurrences(of: decimalSeparator, with: ".")
        return Double(normalized)
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
