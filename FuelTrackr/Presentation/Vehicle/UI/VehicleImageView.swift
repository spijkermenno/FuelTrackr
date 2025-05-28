// MARK: - Package: Presentation

//
//  VehicleImageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 21/04/2025.
//

import SwiftUI
import Domain


public struct VehicleImageView: View {
    public let photoData: Data?

    public init(photoData: Data?) {
        self.photoData = photoData
    }

    public var body: some View {
        Group {
            if let data = photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
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
        .frame(height: 220)
        .cornerRadius(15)
        .clipped()
    }
}
