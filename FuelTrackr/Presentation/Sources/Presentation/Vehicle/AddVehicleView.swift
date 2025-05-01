// MARK: - Package: Presentation

//
//  AddVehicleView.swift
//  FuelTrackr
//

import SwiftUI
import Domain

import SwiftData
import Factory

public struct AddVehicleView: View {
    @Environment(\.modelContext) public var context
    @Environment(\.dismiss) public var dismiss
    @EnvironmentObject public var notificationHandler: NotificationHandler

    @Injected public var vehicleViewModel: VehicleViewModel
    @Injected public var settingsViewModel: SettingsViewModel

    @State public var vehicleName: String = ""
    @State public var licensePlate: String = ""
    @State public var purchaseDate: Date = Calendar.current.startOfDay(for: Date())
    @State public var manufacturingDate: Date = Date()
    @State public var mileage: String = ""
    @State public var image: UIImage?
    @State public var isImagePickerPresented = false
    @State public var errorMessage: String?

    public var isUsingMetric: Bool {
        settingsViewModel.isUsingMetric
    }

    public let onSave: () -> Void

    public init(onSave: @escaping () -> Void) {
        self.onSave = onSave
    }

    public var body: some View {
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

                    ToggleSettingsView()

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

    public func saveVehicle() {
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

    public func convertMilesToKm(miles: Int) -> Int {
        let kmValue = Double(miles) * 1.60934
        return Int(ceil(kmValue))
    }
}
