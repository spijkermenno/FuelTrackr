//
//  AddVehicleView.swift
//  FuelTrackr
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
    @State private var purchaseDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var manufacturingDate: Date = Date()
    @State private var mileage: Int? = nil
    @State private var image: UIImage?
    @State private var isImagePickerPresented = false
    
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
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
                        Text(NSLocalizedString("mileage_title", comment: ""))
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField(
                            NSLocalizedString("mileage_placeholder", comment: ""),
                            value: $mileage,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("photo_title", comment: ""))
                            .font(.headline)
                            .foregroundColor(.primary)
                        if let uiImage = image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                        } else {
                            Button(action: {
                                isImagePickerPresented = true
                            }) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.blue)
                                    Text(NSLocalizedString("add_photo_button", comment: ""))
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    Button(action: {
                        saveVehicle()
                        onSave()
                    }) {
                        Text(NSLocalizedString("save_vehicle_button", comment: ""))
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(vehicleName.isEmpty || licensePlate.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(vehicleName.isEmpty || licensePlate.isEmpty || mileage == nil)
                }
                .padding()
                .navigationTitle(NSLocalizedString("welcome_title", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $image)
        }
    }
    
    private func saveVehicle() {
        let newVehicle = Vehicle(
            name: vehicleName,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            mileage: mileage!,
            photo: image?.jpegData(compressionQuality: 0.8)
        )
        context.insert(newVehicle)
        do {
            try context.save()
            
            if purchaseDate <= Date() {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let purchaseDay = calendar.startOfDay(for: purchaseDate)

                let daysUntilPurchase = calendar.dateComponents([.day], from: today, to: purchaseDay).day ?? 0
                
                NotificationManager.shared.scheduleNotification(
                    title: NSLocalizedString("notification_purchase_date_passed_title", comment: ""),
                    body: NSLocalizedString("notification_purchase_date_passed_description", comment: ""),
                    inDays: daysUntilPurchase,
                    atHour: 18,
                    atMinute: 00
                )
            }
        } catch {
            print("Failed to save vehicle: \(error.localizedDescription)")
        }
    }
}

struct TextFieldSection: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            TextField(placeholder, text: $text)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .foregroundColor(.primary)
        }
    }
}

struct DatePickerSection: View {
    let title: String
    @Binding var selection: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                DatePicker("", selection: $selection, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
}
