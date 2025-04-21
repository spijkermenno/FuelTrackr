import SwiftUI

struct EditVehicleSheet: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name: String
    @State private var licensePlate: String
    @State private var purchaseDate: Date
    @State private var manufacturingDate: Date
    @State private var newMileage: String = ""
    @State private var photo: UIImage?
    @State private var isPurchased: Bool
    @State private var errorMessage: String?
    @State private var showImagePicker = false
    @State private var showMileageHistory = false

    // Computed property for whether we are in metric mode.
    private var isMetric: Bool {
        SettingsRepository().isUsingMetric()
    }
    
    init(viewModel: VehicleViewModel) {
        self.viewModel = viewModel
        let vehicle = viewModel.activeVehicle ?? Vehicle(
            name: "", licensePlate: "", purchaseDate: Date(), manufacturingDate: Date()
        )

        _name = State(initialValue: vehicle.name)
        _licensePlate = State(initialValue: vehicle.licensePlate)
        _purchaseDate = State(initialValue: vehicle.purchaseDate)
        _manufacturingDate = State(initialValue: vehicle.manufacturingDate)
        _photo = State(initialValue: vehicle.photo.flatMap { UIImage(data: $0) })
        _isPurchased = State(initialValue: vehicle.isPurchased)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    if let photo = photo {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fill)
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
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                Text(NSLocalizedString("tap_to_select_photo", comment: ""))
                                    .foregroundColor(.secondary)
                            )
                            .padding()
                            .onTapGesture {
                                showImagePicker = true
                            }
                    }
                    
                    InputField(
                        title: NSLocalizedString("vehicle_name_title", comment: ""),
                        placeholder: NSLocalizedString("vehicle_name_placeholder", comment: ""),
                        text: $name
                    )
                    
                    InputField(
                        title: NSLocalizedString("license_plate_title", comment: ""),
                        placeholder: NSLocalizedString("license_plate_placeholder", comment: ""),
                        text: $licensePlate
                    )
                    
                    DatePicker(NSLocalizedString("purchase_date_title", comment: ""), selection: $purchaseDate, displayedComponents: [.date])
                        .onChange(of: purchaseDate) { newDate in
                            purchaseDate = Calendar.current.startOfDay(for: newDate)
                        }
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    DatePicker(NSLocalizedString("manufacturing_date_title", comment: ""), selection: $manufacturingDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)

                    // Latest mileage display using isMetric to convert if needed.
                    if let latestMileage = viewModel.activeVehicle?.mileages.sorted(by: { $0.date > $1.date }).first {
                        let displayedMileage: String = {
                            if isMetric {
                                return "\(latestMileage.value) km"
                            } else {
                                let miles = Int(Double(latestMileage.value) / 1.60934)
                                return "\(miles) mi"
                            }
                        }()
                        HStack {
                            Text(NSLocalizedString("latest_mileage", comment: ""))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(displayedMileage)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    } else {
                        HStack {
                            Text(NSLocalizedString("latest_mileage", comment: ""))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(NSLocalizedString("no_mileage_recorded", comment: ""))
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button(action: saveVehicle) {
                        Text(NSLocalizedString("save", comment: ""))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .navigationTitle(NSLocalizedString("edit_vehicle_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .padding(.bottom)
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $photo)
        }
    }
    
    private func saveVehicle() {
        guard !name.isEmpty, !licensePlate.isEmpty else {
            errorMessage = NSLocalizedString("all_fields_required_error", comment: "")
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let purchaseDay = calendar.startOfDay(for: purchaseDate)

        if purchaseDay > today {
            let daysUntilPurchase = calendar.dateComponents([.day], from: today, to: purchaseDay).day ?? 0
            
            NotificationManager.shared.scheduleNotification(
                title: NSLocalizedString("notification_purchase_date_passed_title", comment: ""),
                body: NSLocalizedString("notification_purchase_date_passed_description", comment: ""),
                inDays: daysUntilPurchase,
                atHour: 18,
                atMinute: 00
            )
        }

        viewModel.updateVehicle(
            context: context,
            name: name,
            licensePlate: licensePlate,
            purchaseDate: purchaseDate,
            manufacturingDate: manufacturingDate,
            photo: photo?.jpegData(compressionQuality: 0.8),
            isPurchased: purchaseDate <= Date()
        )

        dismiss()
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}
