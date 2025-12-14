// MARK: - Package: Presentation
//
//  EditVehicleSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import SwiftData
import Domain

public struct EditVehicleSheet: View {
    public var viewModel: VehicleViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var licensePlate: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var manufacturingDate: Date = Date()
    @State private var photo: UIImage?
    @State private var isPurchased: Bool = false
    @State private var errorMessage: String?
    @State private var showImagePicker = false

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PhotoPickerSection(photo: $photo, showImagePicker: $showImagePicker)

                    InputField(
                        title: NSLocalizedString("vehicle_name_title", comment: ""),
                        placeholder: NSLocalizedString("vehicle_name_placeholder", comment: ""),
                        text: $name
                    )

                    InputField(
                        title: NSLocalizedString("license_plate_title", comment: ""),
                        placeholder: NSLocalizedString("license_plate_placeholder", comment: ""),
                        text: $licensePlate
                    )

                    DatePickerSection(title: NSLocalizedString("purchase_date_title", comment: ""), selection: $purchaseDate)
                    DatePickerSection(title: NSLocalizedString("manufacturing_date_title", comment: ""), selection: $manufacturingDate)

                    if let vehicle = viewModel.resolvedVehicle(context: context) {
                        LatestMileageSection(vehicle: vehicle, isMetric: viewModel.isUsingMetric)
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: saveVehicle) {
                        Text(NSLocalizedString("save", comment: ""))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
                .onAppear(perform: initializeFields)
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle(NSLocalizedString("edit_vehicle_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $photo)
        }
    }

    private func initializeFields() {
        guard let vehicle = viewModel.resolvedVehicle(context: context) else { return }
        name = vehicle.name
        licensePlate = vehicle.licensePlate
        purchaseDate = vehicle.purchaseDate
        manufacturingDate = vehicle.manufacturingDate
        photo = vehicle.photo.flatMap { UIImage(data: $0) }
        isPurchased = vehicle.isPurchased ?? false
    }

    private func saveVehicle() {
        guard !name.isEmpty, !licensePlate.isEmpty else {
            errorMessage = NSLocalizedString("all_fields_required_error", comment: "")
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let purchaseDay = Calendar.current.startOfDay(for: purchaseDate)

        if purchaseDay > today {
            let daysUntilPurchase = Calendar.current.dateComponents([.day], from: today, to: purchaseDay).day ?? 0

            // Schedule notification if needed
        }

        guard let vehicle = viewModel.resolvedVehicle(context: context) else { return }
        viewModel.updateVehicle(
            name: name,
            brand: vehicle.brand,
            model: vehicle.model,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            photo: photo?.jpegData(compressionQuality: 0.8),
            context: context
        )

        dismiss()
    }
}
