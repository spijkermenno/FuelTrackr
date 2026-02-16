//
//  OnboardingViewModel.swift
//  FuelTrackr
//
//  Manages the state and flow of the onboarding process
//

import Foundation
import Domain
import SwiftUI

public final class OnboardingViewModel: ObservableObject {
    // MARK: - Published State
    @Published public var currentStep: OnboardingStep = .welcome
    @Published public var isUsingMetric: Bool = true
    @Published public var vehicleName: String = ""
    @Published public var vehicleFuelType: FuelType = .unknown
    @Published public var purchaseDate: Date = Calendar.current.startOfDay(for: Date())
    @Published public var productionDate: Date = Date()
    @Published public var currentMileage: String = ""
    @Published public var vehiclePhoto: UIImage?
    
    // MARK: - Use Cases
    private let setIsUsingMetric: SetUsingMetricUseCase
    private let getIsUsingMetric: GetUsingMetricUseCase
    
    // MARK: - Computed Properties
    public var totalSteps: Int { 9 }
    
    /// Returns the step index for progress indicator (excludes welcome screen, accounts for skipped step 8)
    public var currentStepIndex: Int {
        switch currentStep {
        case .welcome:
            return 0 // Welcome doesn't show progress
        case .notifications:
            return 1 // Shows "1 of 9" in design
        case .tracking:
            return 2 // Shows "2 of 9" in design
        case .unitSelection:
            return 3 // Shows "3 of 9" in design
        case .vehicleName:
            return 4 // Shows "4 of 9" in design
        case .vehicleFuelType:
            return 5 // Shows "5 of 9" in design
        case .optionalDetails:
            return 6 // Shows "6 of 9" in design
        case .currentMileage:
            return 7 // Shows "7 of 9" in design
        case .addPhoto:
            return 8 // Shows "8 of 9" in design (step 8 is skipped)
        case .completion:
            return 9 // Completion doesn't show progress, but if it did it would be 9
        }
    }
    
    public var progress: Double { Double(currentStepIndex) / Double(totalSteps) }
    
    // MARK: - Initialization
    public init(
        setIsUsingMetric: SetUsingMetricUseCase = SetUsingMetricUseCase(),
        getIsUsingMetric: GetUsingMetricUseCase = GetUsingMetricUseCase()
    ) {
        self.setIsUsingMetric = setIsUsingMetric
        self.getIsUsingMetric = getIsUsingMetric
        loadInitialSettings()
    }
    
    // MARK: - Methods
    private func loadInitialSettings() {
        isUsingMetric = getIsUsingMetric()
    }
    
    public func nextStep() {
        guard let nextStep = currentStep.next() else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = nextStep
        }
    }
    
    public func previousStep() {
        guard let previousStep = currentStep.previous() else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = previousStep
        }
    }
    
    public func updateMetricSystem(_ isMetric: Bool) {
        isUsingMetric = isMetric
        setIsUsingMetric(isMetric)
    }
    
    public func updateVehicleFuelType(_ fuelType: FuelType) {
        vehicleFuelType = fuelType
    }
    
    public func canProceedFromCurrentStep() -> Bool {
        switch currentStep {
        case .welcome:
            return true
        case .notifications:
            return true // Permission step, can always proceed
        case .tracking:
            return true // Permission step, can always proceed
        case .unitSelection:
            return true
        case .vehicleName:
            return !vehicleName.trimmingCharacters(in: .whitespaces).isEmpty
        case .vehicleFuelType:
            return vehicleFuelType != .unknown
        case .optionalDetails:
            return true // Optional step, can always proceed
        case .currentMileage:
            return !currentMileage.trimmingCharacters(in: .whitespaces).isEmpty && validateMileage()
        case .addPhoto:
            return true // Optional step, can always proceed
        case .completion:
            return true
        }
    }
    
    public func validateMileage() -> Bool {
        guard let mileageValue = Int(currentMileage.replacingOccurrences(of: ",", with: "")), mileageValue >= 0 else {
            return false
        }
        return true
    }
    
    public func getValidatedMileage() -> Int? {
        guard validateMileage() else { return nil }
        let cleanedMileage = currentMileage.replacingOccurrences(of: ",", with: "")
        guard let mileageValue = Int(cleanedMileage) else { return nil }
        return isUsingMetric ? mileageValue : convertMilesToKm(miles: mileageValue)
    }
    
    private func convertMilesToKm(miles: Int) -> Int {
        let kmValue = Double(miles) * 1.60934
        return Int(ceil(kmValue))
    }
    
    public func createVehicle() -> Vehicle {
        return Vehicle(
            name: vehicleName.isEmpty ? "My Vehicle" : vehicleName,
            fuelType: vehicleFuelType,
            purchaseDate: purchaseDate,
            manufacturingDate: productionDate,
            photo: vehiclePhoto?.jpegData(compressionQuality: 0.8)
        )
    }
}

// MARK: - OnboardingStep Enum
public enum OnboardingStep: Int, CaseIterable {
    case welcome = 1
    case notifications = 2
    case tracking = 3
    case unitSelection = 4
    case vehicleName = 5
    case vehicleFuelType = 6
    case optionalDetails = 7
    case currentMileage = 8
    case addPhoto = 9 // Step 8 is skipped in the design
    case completion = 10
    
    /// Returns the next step in the onboarding flow, or nil if this is the last step
    public func next() -> OnboardingStep? {
        let allCases = Self.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex < allCases.count - 1 else {
            return nil
        }
        return allCases[currentIndex + 1]
    }
    
    /// Returns the previous step in the onboarding flow, or nil if this is the first step
    public func previous() -> OnboardingStep? {
        let allCases = Self.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex > 0 else {
            return nil
        }
        return allCases[currentIndex - 1]
    }
    
    public var title: String {
        switch self {
        case .welcome:
            return NSLocalizedString("onboarding_welcome_title", comment: "")
        case .notifications:
            return NSLocalizedString("onboarding_notifications_title", comment: "")
        case .tracking:
            return NSLocalizedString("onboarding_tracking_title", comment: "")
        case .unitSelection:
            return NSLocalizedString("onboarding_unit_selection_title", comment: "")
        case .vehicleName:
            return NSLocalizedString("onboarding_vehicle_name_title", comment: "")
        case .vehicleFuelType:
            return NSLocalizedString("onboarding_vehicle_fuel_type_title", comment: "")
        case .optionalDetails:
            return NSLocalizedString("onboarding_optional_details_title", comment: "")
        case .currentMileage:
            return NSLocalizedString("onboarding_current_mileage_title", comment: "")
        case .addPhoto:
            return NSLocalizedString("onboarding_add_photo_title", comment: "")
        case .completion:
            return NSLocalizedString("onboarding_completion_title", comment: "")
        }
    }
}
