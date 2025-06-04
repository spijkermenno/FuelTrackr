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
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(Theme.dimensions.radiusCard)
                    .shadow(color: Color.black.opacity(0.1),radius: 6,x: 0,y: 0)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(Theme.dimensions.radiusCard)
                    .shadow(color: Color.black.opacity(0.1),radius: 6,x: 0,y: 0)
                    .clipped()
            }
        }
    }
}
