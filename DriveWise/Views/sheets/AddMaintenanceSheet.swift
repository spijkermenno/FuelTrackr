//
//  AddMaintenanceSheet.swift
//  DriveWise
//

import SwiftUI

struct AddMaintenanceSheet: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var selectedType: MaintenanceType = .tires
    @State private var cost = ""
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("maintenance_details", comment: "Maintenance Details"))) {
                    // Maintenance Type Picker
                    Picker(NSLocalizedString("maintenance_type", comment: "Maintenance Type"), selection: $selectedType) {
                        ForEach(MaintenanceType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    // Additional Notes for "Other"
                    if selectedType == .other {
                        TextField(NSLocalizedString("other_notes", comment: "Other Notes"), text: $notes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // Cost
                    TextField(NSLocalizedString("cost_label", comment: "Cost"), text: $cost)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .navigationTitle(NSLocalizedString("add_maintenance_title", comment: "Add Maintenance Title"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "Cancel button")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "Save button")) {
                        guard let costValue = Double(cost) else { return }

                        if viewModel.saveMaintenance(
                            context: context,
                            maintenanceType: selectedType,
                            cost: costValue,
                            date: Date(),
                            notes: selectedType == .other ? notes : nil
                        ) {
                            dismiss()
                        }
                    }
                    .disabled(cost.isEmpty || (selectedType == .other && notes.isEmpty))
                }
            }
        }
    }
}
