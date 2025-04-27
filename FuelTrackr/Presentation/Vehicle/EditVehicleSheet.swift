//
//  EditVehicleSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import SwiftData

struct EditVehicleSheet: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name: String
    @State private var licensePlate: String
    @State private var purchaseDate: Date
    @State private var manufacturingDate: Date
    @State private var newMileage: String = ""
    @State private var photo: UIImage?
    @State private var isPurchased: Bool
    @State private var errorMessage: String?
    @State private var showImagePicker = false
        
    init(viewModel: VehicleViewModel) {
        self.viewModel = viewModel
        let vehicle = viewModel.activeVehicle ?? Vehicle(name: "", licensePlate: "", purchaseDate: Date(), manufacturingDate: Date())
        
        _name = State(initialValue: vehicle.name)
        _licensePlate = State(initialValue: vehicle.licensePlate)
        _purchaseDate = State(initialValue: vehicle.purchaseDate)
        _manufacturingDate = State(initialValue: vehicle.manufacturingDate)
        _photo = State(initialValue: vehicle.photo.flatMap { UIImage(data: $0) })
        _isPurchased = State(initialValue: vehicle.isPurchased)
    }
    
    var body: some View {
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
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle(NSLocalizedString("edit_vehicle_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $photo)
        }
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
            
            NotificationManager.shared.scheduleNotification(
                title: NSLocalizedString("notification_purchase_date_passed_title", comment: ""),
                body: NSLocalizedString("notification_purchase_date_passed_description", comment: ""),
                inDays: daysUntilPurchase,
                atHour: 18,
                atMinute: 0
            )
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

struct PhotoPickerSection: View {
    @Binding var photo: UIImage?
    @Binding var showImagePicker: Bool
    
    var body: some View {
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

struct LatestMileageSection: View {
    let vehicle: Vehicle?
    let isMetric: Bool
    
    var body: some View {
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
