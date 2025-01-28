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
    @State private var purchaseDate: Date = Date()
    @State private var manufacturingDate: Date = Date()
    @State private var mileage: Int? = nil
    @State private var image: UIImage?
    @State private var isImagePickerPresented = false
    
    let onSave: () -> Void // Callback to notify parent view
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image("icon")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .cornerRadius(35)
                    
                    Text(NSLocalizedString("welcome_subtitle", comment: "Welcome subtitle"))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Vehicle Name
                    TextFieldSection(
                        title: NSLocalizedString("vehicle_name_title", comment: "Vehicle name title"),
                        text: $vehicleName,
                        placeholder: NSLocalizedString("vehicle_name_placeholder", comment: "Vehicle name placeholder")
                    )
                    
                    // License Plate
                    TextFieldSection(
                        title: NSLocalizedString("license_plate_title", comment: "License plate title"),
                        text: $licensePlate,
                        placeholder: NSLocalizedString("license_plate_placeholder", comment: "License plate placeholder")
                    )
                    
                    // Purchase and Manufacturing Dates
                    DatePickerSection(
                        title: NSLocalizedString("purchase_date_title", comment: "Purchase date title"),
                        selection: $purchaseDate
                    )
                    
                    DatePickerSection(
                        title: NSLocalizedString("manufacturing_date_title", comment: "Manufacturing date title"),
                        selection: $manufacturingDate
                    )
                    
                    // Mileage
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("mileage_title", comment: "Mileage title"))
                            .font(.headline)
                        TextField(
                            NSLocalizedString("mileage_placeholder", comment: "Mileage placeholder"),
                            value: $mileage,
                            format: .number
                        )
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Photo Section
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("photo_title", comment: "Photo title"))
                            .font(.headline)
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
                                    Text(NSLocalizedString("add_photo_button", comment: "Add photo button"))
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Save Button
                    Button(action: {
                        saveVehicle()
                        onSave()
                    }) {
                        Text(NSLocalizedString("save_vehicle_button", comment: "Save vehicle button"))
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
                .navigationTitle(NSLocalizedString("welcome_title", comment: "Welcome title"))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
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
            print("Vehicle saved successfully: \(newVehicle.name)")
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
            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
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
            
            HStack {
                DatePicker("", selection: $selection, displayedComponents: .date)
                    .labelsHidden() // Hides the default label
                    .datePickerStyle(.compact) // Uses a compact style
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
