//
//  AddVehicleView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vehicleName: String = ""
    @State private var licensePlate: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var manufacturingDate: Date = Date()
    @State private var mileage: Int = 0
    @State private var image: UIImage?
    let onSave: () -> Void // Callback for saving

    var body: some View {
        Form {
            Section(header: Text("Vehicle Details")) {
                TextField("Name", text: $vehicleName)
                TextField("License Plate", text: $licensePlate)
                DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                DatePicker("Manufacturing Date", selection: $manufacturingDate, displayedComponents: .date)
                TextField("Mileage", value: $mileage, format: .number)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Photo")) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                } else {
                    Button("Add Photo") {
                        // Photo picker logic here
                    }
                }
            }

            Button("Save Vehicle") {
                saveVehicle()
                onSave() // Trigger the callback
            }
            .disabled(vehicleName.isEmpty || licensePlate.isEmpty)
        }
        .navigationTitle("Add Vehicle")
    }

    private func saveVehicle() {
        let newVehicle = Vehicle(
            name: vehicleName,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            mileage: mileage,
            photo: image?.jpegData(compressionQuality: 0.8)
        )
        context.insert(newVehicle)
        do {
            try context.save()
            print("Vehicle saved successfully: \(newVehicle.name)")
        } catch {
            print("Failed to save vehicle: \(error.localizedDescription)")
        }
    }
}
