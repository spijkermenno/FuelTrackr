//
//  ActiveVehicleView.swift
//  DriveWise
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI

struct ActiveVehicleView: View {
    let vehicle: Vehicle
    @Environment(\.modelContext) private var context
    @State private var showDeleteConfirmation = false // State for confirmation dialog
    var onDelete: () -> Void // Callback for dismissal

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(vehicle.name)
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                Text("License Plate: \(vehicle.licensePlate)")
                Text("Mileage: \(vehicle.mileage) km")
                Text("Purchase Date: \(vehicle.purchaseDate, style: .date)")
                Text("Manufacturing Date: \(vehicle.manufacturingDate, style: .date)")
            }

            if let photoData = vehicle.photo, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
            }

            Spacer()

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Text("Delete Vehicle")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .confirmationDialog("Are you sure you want to delete this vehicle?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    deleteVehicle()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .padding()
    }

    private func deleteVehicle() {
        context.delete(vehicle)
        do {
            try context.save()
            print("Vehicle deleted successfully.")
            onDelete() // Trigger the dismissal callback
        } catch {
            print("Error deleting vehicle: \(error.localizedDescription)")
        }
    }
}
