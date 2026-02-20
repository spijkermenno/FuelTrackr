// MARK: - Package: Presentation

//
//  AddMaintenanceSheet.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftUI
import Domain
import ScovilleKit
import FirebaseAnalytics


 struct AddMaintenanceSheet: View {
    @StateObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss
     @Environment(\.modelContext) private var context
    
    @State private var selectedType: MaintenanceType = .tires
    @State private var cost = ""
    @State private var notes = ""
    @State private var mileage = ""
    @State private var date = Date()
    @State private var isFree = false
    @State private var errorMessage: String?
    @State private var mileageWarning: String?
    @State private var keyboardHeight: CGFloat = 0
    @State private var resolvedVehicle: Vehicle?
    
    private var decimalSeparator: String {
        Locale(identifier: GetSelectedCurrencyUseCase()().parsingLocaleIdentifier).decimalSeparator ?? Locale.current.decimalSeparator ?? "."
    }
    
    private var isUsingMetric: Bool {
        viewModel.isUsingMetric
    }
    
     var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    headerSection
                    formSection
                    buttonSection
                }
                .padding(.bottom, keyboardHeight)
                .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            }
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.bottom)
            .onTapGesture { hideKeyboard() }
            .onAppear {
                startKeyboardObserver()
                resolvedVehicle = viewModel.resolvedVehicle(context: context)
            }
            .onDisappear { stopKeyboardObserver() }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("add_maintenance_title", comment: ""))
                .font(.title2.weight(.bold))
                .padding(.top, 30)
            Text(NSLocalizedString("add_maintenance_description", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 32)
        .multilineTextAlignment(.leading)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            maintenanceTypePicker
            
            if selectedType == .other {
                InputField(
                    title: NSLocalizedString("other_notes", comment: ""),
                    placeholder: NSLocalizedString("other_notes_placeholder", comment: ""),
                    text: $notes
                )
            }
            
            InputField(
                title: String(format: NSLocalizedString("cost_label", comment: ""), GetSelectedCurrencyUseCase()().symbol),
                placeholder: NSLocalizedString("cost_placeholder", comment: ""),
                text: $cost,
                keyboardType: .decimalPad
            )
            .disabled(isFree)
            .opacity(isFree ? 0.6 : 1)
            
            Toggle(isOn: $isFree) {
                Text(NSLocalizedString("free_or_warranty", comment: ""))
                    .font(.body)
            }
            .toggleStyle(SwitchToggleStyle(tint: .orange))
            .padding(.horizontal)
            .onChange(of: isFree) {
                if isFree { cost = "0" } else { cost = "" }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                InputField(
                    title: NSLocalizedString("mileage_label", comment: ""),
                    placeholder: NSLocalizedString("mileage_placeholder", comment: ""),
                    text: $mileage,
                    keyboardType: .numberPad,
                    hasError: errorMessage != nil && mileageWarning == nil,
                    hasWarning: mileageWarning != nil
                )
                .accessibilityLabel(NSLocalizedString("mileage_label", comment: ""))
                
                if let warning = mileageWarning {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(warning)
                            .foregroundColor(.orange)
                            .font(.footnote)
                    }
                    .padding(.horizontal, 4)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(warning)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("date_label", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .accessibilityLabel(NSLocalizedString("date_label", comment: ""))
            }
            
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(errorMessage)
            }
        }
        .padding()
        .onChange(of: mileage) { _ in
            validateMileage()
        }
    }
    
    private var maintenanceTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("maintenance_type", comment: ""))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker(NSLocalizedString("maintenance_type", comment: ""), selection: $selectedType) {
                ForEach(MaintenanceType.allCases, id: \.self) { type in
                    Text(type.localized.capitalized)
                        .tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var buttonSection: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Text(NSLocalizedString("cancel", comment: ""))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
            }
            
            Button(action: saveMaintenance) {
                Text(NSLocalizedString("save", comment: ""))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding([.horizontal, .bottom])
    }
    
    // MARK: - Actions
    
    private func saveMaintenance() {
        guard validateAllFields() else { return }
        
        guard let mileageValue = Int(mileage) else { return }
        let costValue: Double = isFree ? 0 : (parseInput(cost) ?? 0)
        
        let mileage = Mileage(value: mileageValue, date: date)
        
        let maintenance = Maintenance(
            type: selectedType,
            cost: costValue,
            isFree: isFree,
            date: date,
            mileage: mileage,
            notes: selectedType == .other ? notes : nil
        )
        
        viewModel.saveMaintenance(maintenance: maintenance, context: context)
        
        // Track maintenance creation
        Task { @MainActor in
            let params: [String: Any] = [
                "type": selectedType.rawValue,
                "cost": String(costValue),
                "is_free": isFree ? "true" : "false",
                "has_notes": (selectedType == .other && !notes.isEmpty) ? "true" : "false"
            ]
            Scoville.track(FuelTrackrEvents.maintenanceTracked, parameters: params)
            Analytics.logEvent(FuelTrackrEvents.maintenanceTracked.rawValue, parameters: params)
        }
        
        dismiss()
    }
    
    private func validateMileage() {
        guard let vehicle = resolvedVehicle,
              !mileage.isEmpty,
              let mileageValue = Int(mileage) else {
            mileageWarning = nil
            return
        }
        
        let previousMileage = getPreviousMileage(from: vehicle)
        
        guard let previousMileage = previousMileage else {
            mileageWarning = nil
            return
        }
        
        // Check if mileage is suspiciously high (more than 2x or more than 10,000 km/miles higher)
        let threshold = isUsingMetric ? 10000 : 6214 // ~10,000 km or ~6,214 miles
        let difference = mileageValue - previousMileage
        
        if mileageValue > previousMileage * 2 || difference > threshold {
            mileageWarning = NSLocalizedString("mileage_suspiciously_high_warning", comment: "")
        } else {
            mileageWarning = nil
        }
    }
    
    /// Gets the previous mileage from vehicle (from latest mileage or latest fuel usage)
    private func getPreviousMileage(from vehicle: Vehicle) -> Int? {
        // Get latest mileage from mileages array
        let latestMileage = vehicle.latestMileage?.value
        
        // Get latest mileage from fuel usages
        let latestFuelMileage = vehicle.fuelUsages
            .compactMap { $0.mileage?.value }
            .max()
        
        // Get latest mileage from maintenances
        let latestMaintenanceMileage = vehicle.maintenances
            .compactMap { $0.mileage?.value }
            .max()
        
        // Return the highest value between all three
        let allMileages = [latestMileage, latestFuelMileage, latestMaintenanceMileage].compactMap { $0 }
        return allMileages.max()
    }
    
    private func validateAllFields() -> Bool {
        if !isFree {
            guard let costValue = parseInput(cost), costValue > 0 else {
                errorMessage = NSLocalizedString("invalid_cost_error", comment: "")
                mileageWarning = nil
                return false
            }
        }
        
        guard let mileageValue = Int(mileage), mileageValue > 0 else {
            errorMessage = NSLocalizedString("invalid_mileage_error", comment: "")
            mileageWarning = nil
            return false
        }
        
        // Validate mileage against previous value
        if let vehicle = resolvedVehicle {
            let previousMileage = getPreviousMileage(from: vehicle)
            if let previousMileage = previousMileage, mileageValue < previousMileage {
                errorMessage = String(format: NSLocalizedString("mileage_too_low_error", comment: ""), previousMileage)
                mileageWarning = nil
                return false
            }
        }
        
        if selectedType == .other && notes.isEmpty {
            errorMessage = NSLocalizedString("invalid_notes_error", comment: "")
            mileageWarning = nil
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    private func parseInput(_ input: String) -> Double? {
        DecimalInputParser.parse(input)
    }
    
    private func startKeyboardObserver() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                DispatchQueue.main.async {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.async {
                keyboardHeight = 0
            }
        }
    }
    
    private func stopKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
