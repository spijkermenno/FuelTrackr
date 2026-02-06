//
//  OnboardingAddPhotoView.swift
//  FuelTrackr
//
//  Step 9: Add vehicle photo
//

import SwiftUI

public struct OnboardingAddPhotoView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var showImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary

    private var hasPhoto: Bool {
        viewModel.vehiclePhoto != nil
    }

    public var body: some View {
        VStack {
            OnboardingHeader(
                title: NSLocalizedString(
                    "onboarding_add_photo_title",
                    comment: "Add a photo of your vehicle"
                ),
                description: NSLocalizedString(
                    "onboarding_add_photo_description",
                    comment: "This helps you recognize it quickly in your overview."
                )
            )
            .padding(.top, 116)

            Spacer()

            if let photo = viewModel.vehiclePhoto {
                VehicleImageView(photoData: viewModel.vehiclePhoto?.pngData())
                    .padding()
                    .transition(.scale.combined(with: .opacity))
            } else {
                Color.clear
                    .frame(width: 200, height: 200)
            }

            Spacer()

            VStack(spacing: 12) {
                if hasPhoto {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.nextStep()
                        }
                    } label: {
                        Text(NSLocalizedString(
                            "onboarding_confirm_photo",
                            comment: "Confirm photo"
                        ))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(OnboardingColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(OnboardingColors.primaryBlue)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button {
                        withAnimation {
                            viewModel.vehiclePhoto = nil
                        }
                    } label: {
                        Text(NSLocalizedString(
                            "onboarding_reset_photo",
                            comment: "Choose another photo"
                        ))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(OnboardingColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                    }
                } else {
                    Button {
                        imageSourceType = .camera
                        showImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text(NSLocalizedString(
                                "onboarding_take_photo",
                                comment: "Take photo"
                            ))
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(OnboardingColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(OnboardingColors.primaryBlue)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button {
                        imageSourceType = .photoLibrary
                        showImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text(NSLocalizedString(
                                "onboarding_choose_from_gallery",
                                comment: "Choose from gallery"
                            ))
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(OnboardingColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(OnboardingColors.primaryBlue)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.nextStep()
                        }
                    } label: {
                        Text(NSLocalizedString(
                            "onboarding_skip_for_now",
                            comment: "Skip for now"
                        ))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(OnboardingColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                    }
                }
            }
            .padding(.bottom, 24)
            .animation(.easeInOut, value: hasPhoto)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                image: $viewModel.vehiclePhoto,
                sourceType: imageSourceType
            )
        }
    }
}
