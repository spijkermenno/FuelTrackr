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
        VStack(alignment: .leading) {
            Text(NSLocalizedString("photo_title", comment: "Title for photo section"))
                .font(.headline)
                .foregroundColor(.primary)

            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange, lineWidth: 2)
                    )
            } else {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)

                        Text(NSLocalizedString("add_photo_button", comment: "Button title for adding a photo"))
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
        }
    }

    public init(image: Binding<UIImage?>, isImagePickerPresented: Binding<Bool>) {
        self._image = image
        self._isImagePickerPresented = isImagePickerPresented
    }
}
