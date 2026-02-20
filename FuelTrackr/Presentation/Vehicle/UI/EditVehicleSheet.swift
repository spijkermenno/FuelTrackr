// MARK: - Package: Presentation
//
//  EditVehicleSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import FirebaseAnalytics
import SwiftData
import Domain
import ScovilleKit

public struct EditVehicleSheet: View {
    public var viewModel: VehicleViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme

    @State private var name: String = ""
    @State private var selectedFuelType: FuelType? = nil
    @State private var purchaseDate: Date = Date()
    @State private var manufacturingDate: Date = Date()
    @State private var photo: UIImage?
    @State private var odometer: String = ""
    @State private var isEditingOdometer = false
    @State private var errorMessage: String?
    @State private var showImagePicker = false
    @State private var showImageSourcePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showOdometerEditAlert = false
    @State private var showOdometerSaveConfirm = false

    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.dimensions.spacingL) {
                    // Photo Section
                    photoSection
                        .padding(.top, Theme.dimensions.spacingM)

                    // Vehicle Name
                    InputField(
                        title: NSLocalizedString("vehicle_name_title", comment: ""),
                        placeholder: NSLocalizedString("vehicle_name_placeholder", comment: ""),
                        text: $name,
                        hasError: !name.isEmpty == false && errorMessage != nil
                    )

                    // Fuel Type Picker
                    fuelTypeSection

                    // Purchase Date
                    DatePickerSection(
                        title: NSLocalizedString("purchase_date_title", comment: ""),
                        selection: $purchaseDate
                    )

                    // Manufacturing Date
                    DatePickerSection(
                        title: NSLocalizedString("manufacturing_date_title", comment: ""),
                        selection: $manufacturingDate
                    )

                    // Odometer / Current Mileage (Editable)
                    if viewModel.resolvedVehicle(context: context) != nil {
                        odometerSection
                    }

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(Theme.typography.footnoteFont)
                            .foregroundColor(colors.error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.dimensions.spacingL)
                    }

                    // Save Button
                    Button(action: saveVehicle) {
                        Text(NSLocalizedString("save", comment: ""))
                            .font(Theme.typography.headlineFont)
                            .foregroundColor(colors.onPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [colors.primary, colors.secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(Theme.dimensions.radiusButton)
                            .shadow(
                                color: colors.primary.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .padding(.top, Theme.dimensions.spacingM)
                    .padding(.bottom, Theme.dimensions.spacingXL)
                }
                .padding(.horizontal, Theme.dimensions.spacingL)
            }
            .background(colors.background)
            .navigationTitle(NSLocalizedString("edit_vehicle_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                    .foregroundColor(colors.primary)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $photo, sourceType: imageSourceType)
        }
        .confirmationDialog(
            NSLocalizedString("select_photo_source", comment: ""),
            isPresented: $showImageSourcePicker,
            titleVisibility: .visible
        ) {
            Button(NSLocalizedString("camera", comment: "")) {
                imageSourceType = .camera
                showImagePicker = true
            }
            Button(NSLocalizedString("photo_library", comment: "")) {
                imageSourceType = .photoLibrary
                showImagePicker = true
            }
            if photo != nil {
                Button(NSLocalizedString("remove_photo", comment: ""), role: .destructive) {
                    photo = nil
                }
            }
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
        }
        .onAppear(perform: initializeFields)
        .alert(NSLocalizedString("odometer_title", comment: ""), isPresented: $showOdometerEditAlert) {
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
            Button(NSLocalizedString("continue", comment: "")) {
                isEditingOdometer = true
            }
        } message: {
            Text(NSLocalizedString("odometer_change_warning", comment: ""))
        }
        .alert(NSLocalizedString("odometer_save_confirm_title", comment: ""), isPresented: $showOdometerSaveConfirm) {
            Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {
                initializeOdometerField()
                isEditingOdometer = false
            }
            Button(NSLocalizedString("odometer_change_confirm", comment: "")) {
                saveOdometerOnly()
            }
        } message: {
            Text(NSLocalizedString("odometer_save_confirm_message", comment: ""))
        }
    }

    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(spacing: Theme.dimensions.spacingM) {
            Text(NSLocalizedString("photo_title", comment: ""))
                .font(Theme.typography.headlineFont)
                .foregroundColor(colors.onBackground)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let currentPhoto = photo {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: currentPhoto)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(Theme.dimensions.radiusButton)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.dimensions.radiusButton)
                                .stroke(colors.border, lineWidth: 1)
                        )

                    Button {
                        photo = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(Theme.dimensions.spacingS)
                }
            } else {
                Button {
                    showImageSourcePicker = true
                } label: {
                    VStack(spacing: Theme.dimensions.spacingM) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(colors.primary)

                        Text(NSLocalizedString("add_photo_button", comment: ""))
                            .font(Theme.typography.bodyFont)
                            .foregroundColor(colors.onSurface)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(colors.surface)
                    .cornerRadius(Theme.dimensions.radiusButton)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.dimensions.radiusButton)
                            .stroke(colors.border, lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Fuel Type Section
    private var fuelTypeSection: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("fuel_type_title", comment: ""))
                .font(Theme.typography.headlineFont)
                .foregroundColor(colors.onBackground)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Theme.dimensions.spacingM) {
                ForEach([FuelType.liquid, .electric, .hydrogen, .unknown], id: \.self) { fuelType in
                    fuelTypeButton(fuelType: fuelType)
                }
            }
        }
    }

    private func fuelTypeButton(fuelType: FuelType) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedFuelType = selectedFuelType == fuelType ? nil : fuelType
            }
        } label: {
            Text(fuelType.localizedName)
                .font(Theme.typography.bodyFont)
                .foregroundColor(
                    selectedFuelType == fuelType ? colors.onPrimary : colors.onBackground
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.dimensions.spacingM)
                .background(
                    selectedFuelType == fuelType ?
                        LinearGradient(
                            colors: [colors.primary, colors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [colors.surface, colors.surface],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                )
                .cornerRadius(Theme.dimensions.radiusButton)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.dimensions.radiusButton)
                        .stroke(
                            selectedFuelType == fuelType ? Color.clear : colors.border,
                            lineWidth: 1
                        )
                )
        }
    }

    // MARK: - Odometer Section
    private var odometerSection: some View {
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("odometer_title", comment: ""))
                .font(Theme.typography.headlineFont)
                .foregroundColor(colors.onBackground)

            if isEditingOdometer {
                InputField(
                    title: viewModel.isUsingMetric ?
                        NSLocalizedString("mileage_title_km", comment: "") :
                        NSLocalizedString("mileage_title_miles", comment: ""),
                    placeholder: viewModel.isUsingMetric ?
                        NSLocalizedString("onboarding_mileage_placeholder_km", comment: "") :
                        NSLocalizedString("onboarding_mileage_placeholder_miles", comment: ""),
                    text: $odometer,
                    keyboardType: .numberPad,
                    hasError: false
                )

                HStack(spacing: Theme.dimensions.spacingM) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        initializeOdometerField()
                        isEditingOdometer = false
                    }
                    .foregroundColor(colors.onSurface)

                    Button(NSLocalizedString("save", comment: "")) {
                        handleOdometerSaveTap()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(colors.primary)
                }
            } else {
                HStack {
                    if let vehicle = viewModel.resolvedVehicle(context: context),
                       let latestMileage = vehicle.latestMileage {
                        Text(formatMileage(latestMileage.value))
                            .font(Theme.typography.headlineFont)
                            .foregroundColor(colors.onBackground)
                    } else {
                        Text("—")
                            .font(Theme.typography.headlineFont)
                            .foregroundColor(colors.onSurface)
                    }
                    Spacer()
                    Button {
                        handleOdometerPencilTap()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colors.primary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(Theme.dimensions.spacingM)
                .background(colors.surface)
                .cornerRadius(Theme.dimensions.radiusButton)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.dimensions.radiusButton)
                        .stroke(colors.border, lineWidth: 1)
                )
            }
        }
    }

    private func handleOdometerPencilTap() {
        guard let vehicle = viewModel.resolvedVehicle(context: context) else { return }
        initializeOdometerField()
        if hasOdometerWarningData(vehicle: vehicle) {
            showOdometerEditAlert = true
        } else {
            isEditingOdometer = true
        }
    }

    private func handleOdometerSaveTap() {
        guard let vehicle = viewModel.resolvedVehicle(context: context) else { return }
        guard let value = parseOdometerValue(), value > 0 else {
            errorMessage = NSLocalizedString("validation_mileage_invalid", comment: "")
            return
        }
        errorMessage = nil
        let originalOdometer = vehicle.latestMileage?.value ?? 0
        guard value != originalOdometer else {
            isEditingOdometer = false
            return
        }
        if hasOdometerWarningData(vehicle: vehicle) {
            showOdometerSaveConfirm = true
        } else {
            saveOdometerOnly()
        }
    }

    private func saveOdometerOnly() {
        guard let value = parseOdometerValue(), value > 0 else { return }
        viewModel.updateOdometer(newValue: value, context: context)
        initializeOdometerField()
        isEditingOdometer = false
    }

    private func initializeOdometerField() {
        guard let vehicle = viewModel.resolvedVehicle(context: context) else { return }
        let currentValue = vehicle.latestMileage?.value ?? 0
        odometer = viewModel.isUsingMetric ? String(currentValue) : String(Int(Double(currentValue) * 0.621371))
    }

    private func hasOdometerWarningData(vehicle: Vehicle) -> Bool {
        !vehicle.fuelUsages.isEmpty || vehicle.maintenances.contains { $0.mileage != nil }
    }

    // MARK: - Helper Methods
    private func initializeFields() {
        guard let vehicle = viewModel.resolvedVehicle(context: context) else { return }
        name = vehicle.name
        selectedFuelType = vehicle.fuelType
        purchaseDate = vehicle.purchaseDate
        manufacturingDate = vehicle.manufacturingDate
        photo = vehicle.photo.flatMap { UIImage(data: $0) }
        initializeOdometerField()
    }

    private func saveVehicle() {
        errorMessage = nil

        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = NSLocalizedString("all_fields_required_error", comment: "")
            return
        }

        guard manufacturingDate <= purchaseDate else {
            errorMessage = NSLocalizedString("manufacturing_date_before_purchase_error", comment: "")
            return
        }

        guard viewModel.resolvedVehicle(context: context) != nil else {
            errorMessage = NSLocalizedString("vehicle_not_found_error", comment: "")
            return
        }

        performSave()
    }

    private func performSave() {
        guard viewModel.resolvedVehicle(context: context) != nil else { return }

        viewModel.updateVehicle(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            fuelType: selectedFuelType,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            photo: photo?.jpegData(compressionQuality: 0.8),
            isPurchased: true,
            context: context
        )

        Task { @MainActor in
            let params: [String: Any] = [
                "fuel_type": selectedFuelType?.rawValue ?? "unknown",
                "has_photo": photo != nil ? "true" : "false"
            ]
            Scoville.track(FuelTrackrEvents.vehicleEdited, parameters: params)
            Analytics.logEvent(FuelTrackrEvents.vehicleEdited.rawValue, parameters: params)
        }

        dismiss()
    }

    private func parseOdometerValue() -> Int? {
        guard let parsed = Int(odometer.trimmingCharacters(in: .whitespaces)), parsed >= 0 else { return nil }
        return viewModel.isUsingMetric ? parsed : Int(Double(parsed) / 0.621371)
    }

    private func formatMileage(_ mileage: Int) -> String {
        if viewModel.isUsingMetric {
            return String(format: "%d km", mileage)
        } else {
            let miles = Int(Double(mileage) * 0.621371)
            return String(format: "%d mi", miles)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
}
