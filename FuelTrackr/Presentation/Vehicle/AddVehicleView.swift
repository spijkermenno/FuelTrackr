//
//  AddVehicleView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vehicleViewModel: VehicleViewModel
    @StateObject private var settingsViewModel = SettingsViewModelFactory.make()

    @State private var vehicleName: String = ""
    @State private var licensePlate: String = ""
    @State private var purchaseDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var manufacturingDate: Date = Date()
    @State private var mileage: String = ""
    @State private var image: UIImage?
    @State private var isImagePickerPresented = false
    @State private var errorMessage: String?

    private var isUsingMetric: Bool {
        settingsViewModel.isUsingMetric
    }

    let onSave: () -> Void

    init(vehicleViewModel: VehicleViewModel, onSave: @escaping () -> Void) {
        _vehicleViewModel = StateObject(wrappedValue: vehicleViewModel)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image("icon")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .cornerRadius(35)

                    Text(NSLocalizedString("welcome_subtitle", comment: ""))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    ToggleSettingsView(viewModel: settingsViewModel)

                    TextFieldSection(
                        title: NSLocalizedString("vehicle_name_title", comment: ""),
                        text: $vehicleName,
                        placeholder: NSLocalizedString("vehicle_name_placeholder", comment: "")
                    )

                    TextFieldSection(
                        title: NSLocalizedString("license_plate_title", comment: ""),
                        text: $licensePlate,
                        placeholder: NSLocalizedString("license_plate_placeholder", comment: "")
                    )

                    DatePickerSection(
                        title: NSLocalizedString("purchase_date_title", comment: ""),
                        selection: $purchaseDate
                    )

                    DatePickerSection(
                        title: NSLocalizedString("manufacturing_date_title", comment: ""),
                        selection: $manufacturingDate
                    )

                    VStack(alignment: .leading) {
                        Text(isUsingMetric ? NSLocalizedString("mileage_title_km", comment: "Mileage in kilometers") : NSLocalizedString("mileage_title_miles", comment: "Mileage in miles"))
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField(
                            NSLocalizedString("mileage_placeholder", comment: ""),
                            text: $mileage
                        )
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .foregroundColor(.primary)
                    }

                    PhotoSection(image: $image, isImagePickerPresented: $isImagePickerPresented)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: saveVehicle) {
                        Text(NSLocalizedString("save_vehicle_button", comment: "Button title for saving vehicle"))
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(vehicleName.isEmpty || licensePlate.isEmpty || mileage.isEmpty ? Color.gray : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(vehicleName.isEmpty || licensePlate.isEmpty || mileage.isEmpty)
                }
                .padding()
                .navigationTitle(NSLocalizedString("welcome_title", comment: "Title for welcome view"))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $image)
        }
    }

    private func saveVehicle() {
        guard let mileageValue = Int(mileage), mileageValue >= 0 else {
            errorMessage = NSLocalizedString("invalid_mileage_error", comment: "")
            return
        }

        let adjustedMileage = isUsingMetric ? mileageValue : convertMilesToKm(miles: mileageValue)

        let newVehicle = Vehicle(
            name: vehicleName,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            photo: image?.jpegData(compressionQuality: 0.8)
        )

        vehicleViewModel.saveVehicle(vehicle: newVehicle, initialMileage: adjustedMileage)

        onSave()
        dismiss()
    }

    private func convertMilesToKm(miles: Int) -> Int {
        let kmValue = Double(miles) * 1.60934
        return Int(ceil(kmValue))
    }
}
