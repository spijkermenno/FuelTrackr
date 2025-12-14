// MARK: - Package: Presentation

//
//  PhotoSection.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain

public struct PhotoSection: View {
    @Binding public var image: UIImage?
    @Binding public var isImagePickerPresented: Bool

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("photo_title", comment: "Title for photo section"))
                .font(.headline)
                .foregroundStyle(.primary)

            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                    )
            } else {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(Theme.colors.primary)

                        Text(NSLocalizedString("add_photo_button", comment: "Button title for adding a photo"))
                            .font(.body)
                            .foregroundColor(Theme.colors.purple)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.vertical)
    }

    public init(image: Binding<UIImage?>, isImagePickerPresented: Binding<Bool>) {
        self._image = image
        self._isImagePickerPresented = isImagePickerPresented
    }
}
