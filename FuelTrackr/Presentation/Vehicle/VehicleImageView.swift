//
//  VehicleImageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//


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
        Group {
            if let data = photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fill)
                    .background(Color.secondary)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .frame(height: 260)
        .cornerRadius(15)
        .clipped()
    }
}