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
import Factory

public struct EditVehicleSheet: View {
    @InjectedObject public var viewModel: VehicleViewModel
//    @Injected public var notificationManager: NotificationManagerProtocol

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

                    InputField(title: NSLocalizedString("vehicle_name_title", comment: ""), placeholder: NSLocalizedString("vehicle_name_placeholder", comment: ""), text: $name)

                    InputField(title: NSLocalizedString("license_plate_title", comment: ""), placeholder: NSLocalizedString("license_plate_placeholder", comment: ""), text: $licensePlate)

                    DatePickerSection(title: NSLocalizedString("purchase_date_title", comment: ""), selection: $purchaseDate)
                    DatePickerSection(title: NSLocalizedString("manufacturing_date_title", comment: ""), selection: $manufacturingDate)

                    LatestMileageSection(vehicle: viewModel.activeVehicle, isMetric: viewModel.isUsingMetric)

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
        guard let vehicle = viewModel.activeVehicle else { return }
        name = vehicle.name
        licensePlate = vehicle.licensePlate
        purchaseDate = vehicle.purchaseDate
        manufacturingDate = vehicle.manufacturingDate
        photo = vehicle.photo.flatMap { UIImage(data: $0) }
        isPurchased = vehicle.isPurchased
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

//            notificationManager.scheduleNotification(
//                title: NSLocalizedString("notification_purchase_date_passed_title", comment: ""),
//                body: NSLocalizedString("notification_purchase_date_passed_description", comment: ""),
//                inDays: daysUntilPurchase,
//                atHour: 18,
//                atMinute: 0
//            )
        }

        viewModel.updateVehicle(
            name: name,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            photo: photo?.jpegData(compressionQuality: 0.8)
        )

        dismiss()
    }
}

public struct PhotoPickerSection: View {
    @Binding var photo: UIImage?
    @Binding var showImagePicker: Bool
    
    public var body: some View {
        Group {
            if let photo = photo {
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxHeight: 250)
                    .background(Color.secondary)
                    .cornerRadius(15)
                    .clipped()
                    .onTapGesture {
                        showImagePicker = true
                    }
            } else {
                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Text(NSLocalizedString("tap_to_select_photo", comment: ""))
                            .foregroundColor(.secondary)
                    )
                    .padding()
                    .onTapGesture {
                        showImagePicker = true
                    }
            }
        }
    }
}

public struct LatestMileageSection: View {
    let vehicle: Vehicle?
    let isMetric: Bool
    
    public var body: some View {
        let latestMileage = vehicle?.mileages.sorted(by: { $0.date > $1.date }).first
        
        HStack {
            Text(NSLocalizedString("latest_mileage", comment: ""))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let mileage = latestMileage {
                Text(isMetric ? "\(mileage.value) km" : "\(Int(Double(mileage.value) / 1.60934)) mi")
                    .foregroundColor(.primary)
            } else {
                Text(NSLocalizedString("no_mileage_recorded", comment: ""))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}
