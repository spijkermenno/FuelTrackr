// MARK: - Package: Presentation

//
//  ImagePicker.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 24/01/2025.
//

import SwiftUI
import Domain

public struct ImagePicker: UIViewControllerRepresentable {
    @Binding public var image: UIImage?

    public init(image: Binding<UIImage?>) {
        self._image = image
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        public let parent: ImagePicker

        public init(_ parent: ImagePicker) {
            self.parent = parent
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.image = uiImage
            } else if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
