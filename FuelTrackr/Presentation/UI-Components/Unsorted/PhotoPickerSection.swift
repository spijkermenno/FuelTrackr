//
//  PhotoPickerSection.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/05/2025.
//

import SwiftUI

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
