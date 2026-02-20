//
//  AddFuelUsageSheet.swift
//  FuelTrackr
//

import SwiftUI
import Domain
import SwiftData

private struct ContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct AddFuelUsageSheet: View {
    @StateObject var vehicleViewModel: VehicleViewModel
    @StateObject private var viewModel = AddFuelUsageViewModel()

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme

    @State private var resolvedVehicle: Vehicle?
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardShowObserver: Any?
    @State private var keyboardHideObserver: Any?
    @State private var contentHeight: CGFloat = 480
    
    private var mileagePlaceholder: String {
        let currentMileage = resolvedVehicle?.mileages.last?.value ?? 0
        return viewModel.displayMileagePlaceholder(currentMileage: currentMileage)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Theme.dimensions.spacingL) {
                        HeaderSection()
                        if let vehicle = resolvedVehicle {
                            InputSection(
                                liters: $viewModel.liters,
                                cost: $viewModel.cost,
                                mileage: $viewModel.mileage,
                                entryDate: $viewModel.entryDate,
                                mileagePlaceholder: mileagePlaceholder,
                                errorMessage: viewModel.errorMessage,
                                mileageWarning: viewModel.mileageWarning,
                                litersError: viewModel.litersError,
                                costError: viewModel.costError,
                                mileageError: viewModel.mileageError,
                                fuelType: vehicle.fuelType,
                                isUsingMetric: vehicleViewModel.isUsingMetric,
                                showSaveButton: false,
                                onSave: saveFuelUsage
                            )
                        } else {
                            InputSection(
                                liters: $viewModel.liters,
                                cost: $viewModel.cost,
                                mileage: $viewModel.mileage,
                                entryDate: $viewModel.entryDate,
                                mileagePlaceholder: mileagePlaceholder,
                                errorMessage: viewModel.errorMessage,
                                mileageWarning: viewModel.mileageWarning,
                                litersError: viewModel.litersError,
                                costError: viewModel.costError,
                                mileageError: viewModel.mileageError,
                                fuelType: nil,
                                isUsingMetric: vehicleViewModel.isUsingMetric,
                                showSaveButton: false,
                                onSave: saveFuelUsage
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, Theme.dimensions.spacingSection)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: ContentHeightKey.self, value: geo.size.height)
                        }
                    )
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture { hideKeyboard() }

                ActionButtons(isPartialFill: nil, onSave: saveFuelUsage)
                    .padding(.horizontal, Theme.dimensions.spacingSection)
                    .padding(.top, Theme.dimensions.spacingM)
                    .padding(.bottom, Theme.dimensions.spacingXL)
            }
            .padding(.bottom, keyboardHeight)
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                resolvedVehicle = vehicleViewModel.resolvedVehicle(context: context)
                startKeyboardObserver()
            }
            .onDisappear {
                stopKeyboardObserver()
            }
            .onPreferenceChange(ContentHeightKey.self) { height in
                guard height > 0 else { return }
                let buttonArea: CGFloat = 100
                let warningExtra: CGFloat = !Calendar.current.isDateInToday(viewModel.entryDate) ? 65 : 0
                let maxHeight = UIScreen.main.bounds.height * 0.9
                contentHeight = min(height + buttonArea + warningExtra, maxHeight)
            }
            .onChange(of: viewModel.entryDate) { _, newDate in
                if !Calendar.current.isDateInToday(newDate) {
                    let warningExtra: CGFloat = 65
                    let maxHeight = UIScreen.main.bounds.height * 0.9
                    contentHeight = min(contentHeight + warningExtra, maxHeight)
                }
            }
        }
        .presentationDetents([.height(contentHeight)])
        .presentationBackground(Color(UIColor.systemGroupedBackground))
    }

    private func startKeyboardObserver() {
        keyboardShowObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                Task { @MainActor in
                    keyboardHeight = frame.height
                }
            }
        }
        keyboardHideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                keyboardHeight = 0
            }
        }
    }

    private func stopKeyboardObserver() {
        if let ob = keyboardShowObserver {
            NotificationCenter.default.removeObserver(ob)
        }
        if let ob = keyboardHideObserver {
            NotificationCenter.default.removeObserver(ob)
        }
    }
    
    private func saveFuelUsage() {
        hideKeyboard()
        if viewModel.saveFuelUsage(activeVehicle: resolvedVehicle, context: context) {
            // Reset the form after successful save
            viewModel.liters = ""
            viewModel.cost = ""
            viewModel.mileage = ""
            viewModel.entryDate = Date()
            viewModel.errorMessage = nil
            viewModel.mileageWarning = nil
            viewModel.litersError = false
            viewModel.costError = false
            viewModel.mileageError = false
            dismiss()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct HeaderSection: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingS) {
            Text(NSLocalizedString("add_fuel_usage_title", comment: ""))
                .font(Theme.typography.titleFont)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Theme.dimensions.spacingSection)
            
            Text(NSLocalizedString("add_fuel_usage_description", comment: ""))
                .font(Theme.typography.captionFont)
                .foregroundColor(colors.onSurface)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct InputSection: View {
    @Binding var liters: String
    @Binding var cost: String
    @Binding var mileage: String
    @Binding var entryDate: Date
    var isPartialFill: Binding<Bool>?

    let mileagePlaceholder: String
    let errorMessage: String?
    let mileageWarning: String?
    let litersError: Bool
    let costError: Bool
    let mileageError: Bool
    let showPartialFillToggle: Bool
    let showSaveButton: Bool
    let fuelType: FuelType?
    let isUsingMetric: Bool

    var onSave: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    init(
        liters: Binding<String>,
        cost: Binding<String>,
        mileage: Binding<String>,
        entryDate: Binding<Date>,
        mileagePlaceholder: String,
        errorMessage: String?,
        mileageWarning: String?,
        litersError: Bool,
        costError: Bool,
        mileageError: Bool,
        fuelType: FuelType? = nil,
        isUsingMetric: Bool = true,
        isPartialFill: Binding<Bool>? = nil,
        showPartialFillToggle: Bool = false,
        showSaveButton: Bool = true,
        onSave: @escaping () -> Void
    ) {
        self._liters = liters
        self._cost = cost
        self._mileage = mileage
        self._entryDate = entryDate
        self.isPartialFill = isPartialFill
        self.mileagePlaceholder = mileagePlaceholder
        self.errorMessage = errorMessage
        self.mileageWarning = mileageWarning
        self.litersError = litersError
        self.costError = costError
        self.mileageError = mileageError
        self.showPartialFillToggle = showPartialFillToggle
        self.showSaveButton = showSaveButton
        self.fuelType = fuelType
        self.isUsingMetric = isUsingMetric
        self.onSave = onSave
    }
    
    private var fuelAmountLabel: String {
        let fuelTypeToUse = fuelType ?? .liquid
        switch (fuelTypeToUse, isUsingMetric) {
        case (.liquid, true): return NSLocalizedString("liters_label", comment: "")
        case (.liquid, false): return NSLocalizedString("gallons_label", comment: "")
        case (.electric, _): return NSLocalizedString("kwh_label", comment: "")
        case (.hydrogen, _): return NSLocalizedString("kg_h2_label", comment: "")
        case (.unknown, _): return NSLocalizedString("fuel_amount_label", comment: "")
        }
    }
    
    private var fuelAmountPlaceholder: String {
        let fuelTypeToUse = fuelType ?? .liquid
        switch (fuelTypeToUse, isUsingMetric) {
        case (.liquid, true): return NSLocalizedString("liters_placeholder", comment: "")
        case (.liquid, false): return NSLocalizedString("gallons_placeholder", comment: "")
        case (.electric, _): return NSLocalizedString("kwh_placeholder", comment: "")
        case (.hydrogen, _): return NSLocalizedString("kg_h2_placeholder", comment: "")
        case (.unknown, _): return NSLocalizedString("fuel_amount_placeholder", comment: "")
        }
    }
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        VStack(alignment: .leading, spacing: Theme.dimensions.spacingM) {
            InputField(
                title: fuelAmountLabel,
                placeholder: fuelAmountPlaceholder,
                text: $liters,
                keyboardType: .decimalPad,
                hasError: litersError
            )
            .accessibilityLabel(fuelAmountLabel)
            
            InputField(
                title: String(format: NSLocalizedString("cost_label", comment: ""), GetSelectedCurrencyUseCase()().symbol),
                placeholder: NSLocalizedString("cost_placeholder", comment: ""),
                text: $cost,
                keyboardType: .decimalPad,
                hasError: costError
            )
            .accessibilityLabel(String(format: NSLocalizedString("cost_label", comment: ""), GetSelectedCurrencyUseCase()().symbol))
            
            VStack(alignment: .leading, spacing: 4) {
                InputField(
                    title: NSLocalizedString("mileage_label", comment: ""),
                    placeholder: mileagePlaceholder,
                    text: $mileage,
                    keyboardType: .numberPad,
                    hasError: mileageError,
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
                            .font(Theme.typography.footnoteFont)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(warning)
                }
            }
            
            FuelEntryDateField(date: $entryDate)

            if !Calendar.current.isDateInToday(entryDate) {
                Text(NSLocalizedString("fuel_entry_past_warning", comment: ""))
                    .font(Theme.typography.footnoteFont)
                    .foregroundColor(colors.onSurface.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .accessibilityLabel(NSLocalizedString("fuel_entry_past_warning", comment: ""))
            }

            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(colors.error)
                        .font(.caption)
                    Text(error)
                        .foregroundColor(colors.error)
                        .font(Theme.typography.footnoteFont)
                }
                .multilineTextAlignment(.leading)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(error)
            }
            
            if showSaveButton {
                ActionButtons(
                    isPartialFill: showPartialFillToggle ? isPartialFill : nil,
                    onSave: onSave
                )
                .padding(.top, Theme.dimensions.spacingM)
            }
        }
    }
}

struct FuelEntryDateField: View {
    @Binding var date: Date
    @State private var showDatePicker = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "d MMMM"
        let datePart = formatter.string(from: date).lowercased()
        if Calendar.current.isDateInToday(date) {
            return "\(NSLocalizedString("fuel_entry_date_today", comment: "")), \(datePart)"
        }
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date).lowercased()
    }
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        Button(action: { showDatePicker = true }) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colors.onSurface.opacity(0.6))
                Text(formattedDateString)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(colors.onSurface.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(NSLocalizedString("fuel_entry_date_label", comment: ""))
        .accessibilityHint(NSLocalizedString("fuel_entry_date_today", comment: ""))
        .sheet(isPresented: $showDatePicker) {
            FuelEntryDatePickerSheet(date: $date, onDismiss: { showDatePicker = false })
        }
    }
}

private struct FuelEntryDatePickerSheet: View {
    @Binding var date: Date
    let onDismiss: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        NavigationStack {
            DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
            .navigationTitle(NSLocalizedString("fuel_entry_date_label", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("done", comment: "")) {
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

struct ActionButtons: View {
    var isPartialFill: Binding<Bool>?
    var onSave: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = Theme.colors(for: colorScheme)
        
        VStack(spacing: Theme.dimensions.spacingM) {
            // Partial/Full Fill Button (only shown in edit mode)
            if let isPartialFillBinding = isPartialFill {
                if isPartialFillBinding.wrappedValue {
                    // Currently partial - show "Mark as Full Fill" button
                    Button(action: {
                        isPartialFillBinding.wrappedValue = false
                    }) {
                        Text(NSLocalizedString("mark_as_full_fill", comment: ""))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(colors.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.dimensions.radiusButton)
                                    .stroke(colors.primary, lineWidth: 1.5)
                            )
                    }
                } else {
                    // Currently full - show "Mark as Partial Fill" button
                    Button(action: {
                        isPartialFillBinding.wrappedValue = true
                    }) {
                        Text(NSLocalizedString("mark_as_partial_fill", comment: ""))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.dimensions.radiusButton)
                                    .stroke(.orange, lineWidth: 1.5)
                            )
                    }
                }
            }
            
            Button(NSLocalizedString("save", comment: ""), action: onSave)
                .frame(maxWidth: .infinity)
                .padding()
                .background(colors.primary)
                .foregroundColor(colors.onPrimary)
                .cornerRadius(Theme.dimensions.radiusButton)
        }
        .padding(.bottom, Theme.dimensions.spacingXL)
    }
}

// MARK: - Preview
@MainActor
private func makeAddFuelPreviewContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Vehicle.self, FuelUsage.self, Maintenance.self, Mileage.self,
        configurations: config
    )
    let context = container.mainContext
    let calendar = Calendar.current

    let vehicle = Vehicle(
        name: "My Volkswagen Golf",
        fuelType: .liquid,
        purchaseDate: calendar.date(byAdding: .year, value: -2, to: Date())!,
        manufacturingDate: calendar.date(byAdding: .year, value: -3, to: Date())!,
        photo: nil,
        isPurchased: true
    )
    context.insert(vehicle)

    let m1 = Mileage(value: 85_000, date: calendar.date(byAdding: .day, value: -60, to: Date())!, vehicle: vehicle)
    let m2 = Mileage(value: 85_400, date: calendar.date(byAdding: .day, value: -30, to: Date())!, vehicle: vehicle)
    context.insert(m1)
    context.insert(m2)
    vehicle.mileages = [m1, m2]

    try! context.save()
    return container
}

#Preview("Add Fuel Usage - With Vehicle") {
    let container = makeAddFuelPreviewContainer()
    let viewModel = VehicleViewModel()
    viewModel.loadActiveVehicle(context: container.mainContext)

    return AddFuelUsageSheetPreviewWrapper(
        showSheet: true,
        sheetContent: {
            AddFuelUsageSheet(vehicleViewModel: viewModel)
                .presentationDragIndicator(.visible)
        }
    )
    .modelContainer(container)
}

#Preview("Add Fuel Usage - No Vehicle") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Vehicle.self, FuelUsage.self, Maintenance.self, Mileage.self,
        configurations: config
    )
    let viewModel = VehicleViewModel()

    return AddFuelUsageSheetPreviewWrapper(
        showSheet: true,
        sheetContent: {
            AddFuelUsageSheet(vehicleViewModel: viewModel)
                .presentationDragIndicator(.visible)
        }
    )
    .modelContainer(container)
}

private struct AddFuelUsageSheetPreviewWrapper<SheetContent: View>: View {
    let showSheet: Bool
    @ViewBuilder let sheetContent: () -> SheetContent

    var body: some View {
        Color.clear
            .sheet(isPresented: .constant(showSheet)) {
                sheetContent()
            }
    }
}
