//
//  VehicleImageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI

struct VehicleImageView: View {
    let photoData: Data?

    var body: some View {
        if let data = photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1.0, contentMode: .fill)
                .frame(height: 260)
                .background(Color.secondary)
                .cornerRadius(15)
                .clipped()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(height: 260)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(15)
        }
    }
}
