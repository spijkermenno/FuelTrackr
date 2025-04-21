import SwiftUI

struct MonthlyRecapSheet: View {
    @ObservedObject var viewModel: VehicleViewModel

      /// Pass this value from the parent. Defaults to false.
      let showPreviousMonth: Bool

      // State for the selected month and year.
      @State private var selectedMonth: Int
      @State private var selectedYear: Int

      init(viewModel: VehicleViewModel, showPreviousMonth: Bool = false) {
          self.viewModel = viewModel
          self.showPreviousMonth = showPreviousMonth
          
          // Calculate the initial date based on showPreviousMonth.
          let date: Date = {
              if showPreviousMonth {
                  return Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
              } else {
                  return Date()
              }
          }()
          
          _selectedMonth = State(initialValue: Calendar.current.component(.month, from: date))
          _selectedYear = State(initialValue: Calendar.current.component(.year, from: date))
      }
    
    // Compute recap values from the view model using the adjusted month and year.
    private var kmDriven: Int { viewModel.kmDriven(forMonth: selectedMonth, year: selectedYear) }
    private var totalFuelUsed: Double { viewModel.fuelUsed(forMonth: selectedMonth, year: selectedYear) }
    private var totalFuelCost: Double { viewModel.fuelCost(forMonth: selectedMonth, year: selectedYear) }
    private var averageFuelUsage: Double { viewModel.averageFuelUsage(forMonth: selectedMonth, year: selectedYear) }
    
    // Check the unit system from your settings.
    private var isMetric: Bool { SettingsRepository().isUsingMetric() }
    
    // Computed display values.
    private var displayedDistance: String {
        if isMetric {
            return "\(kmDriven) km"
        } else {
            let miles = Double(kmDriven) / 1.60934
            return String(format: "%.0f mi", miles)
        }
    }
    
    private var displayedFuelUsed: String {
        if isMetric {
            return String(format: "%.2f L", totalFuelUsed)
        } else {
            let gallons = totalFuelUsed * 0.264172
            return String(format: "%.2f gal", gallons)
        }
    }
    
    private var displayedAverage: String {
        if isMetric {
            return String(format: "%.2f km/L", averageFuelUsage)
        } else {
            let mpg = averageFuelUsage * 2.35215
            return String(format: "%.2f mi/gal", mpg)
        }
    }
    
    // Dummy comparison text that calculates the percentage change from the previous month relative to the adjusted month.
    private var comparisonText: String? {
        var previousMonth = selectedMonth
        var previousYear = selectedYear
        if selectedMonth > 1 {
            previousMonth -= 1
        } else {
            previousMonth = 12
            previousYear -= 1
        }
        
        let currentKm = kmDriven
        let previousKm = viewModel.kmDriven(forMonth: previousMonth, year: previousYear)
        
        guard previousKm > 0 else { return nil }
        
        if kmDriven == 0 { return nil }
        
        let change = (Double(currentKm - previousKm) / Double(previousKm)) * 100
        return String(format: NSLocalizedString("comparison_result", comment: "Compared to previous month with percentage"), change)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Month Navigation Header
                MonthNavigationHeader(selectedMonth: $selectedMonth, selectedYear: $selectedYear)
                
                // If no recap data is available, show an empty state view.
                if kmDriven == 0 && totalFuelUsed == 0 && totalFuelCost == 0 {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        Text(NSLocalizedString("no_data_available", comment: "Empty state message when no recap data is available"))
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    // Recap Data Card.
                    RecapCard(
                        displayedDistance: displayedDistance,
                        displayedFuelUsed: displayedFuelUsed,
                        displayedFuelCost: String(format: "€%.2f", totalFuelCost),
                        displayedAverage: displayedAverage,
                        comparisonText: comparisonText
                    )
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Month Navigation Header

struct MonthNavigationHeader: View {
    @Binding var selectedMonth: Int
    @Binding var selectedYear: Int
    
    // Computed property to check if the next month would be in the future.
    private var isNextMonthInFuture: Bool {
        var nextMonth = selectedMonth
        var nextYear = selectedYear
        if selectedMonth < 12 {
            nextMonth += 1
        } else {
            nextMonth = 1
            nextYear += 1
        }
        let now = Date()
        let currentComponents = Calendar.current.dateComponents([.year, .month], from: now)
        if let currentYear = currentComponents.year, let currentMonth = currentComponents.month {
            return nextYear > currentYear || (nextYear == currentYear && nextMonth > currentMonth)
        }
        return false
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            
            Button(action: {
                if selectedMonth > 1 {
                    selectedMonth -= 1
                } else {
                    selectedMonth = 12
                    selectedYear -= 1
                }
            }) {
                Image(systemName: "chevron.left")
            }
            
            Spacer()
            
            if let monthDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) {
                Text(monthDate, format: Date.FormatStyle().month(.wide).year())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: {
                if selectedMonth < 12 {
                    selectedMonth += 1
                } else {
                    selectedMonth = 1
                    selectedYear += 1
                }
            }) {
                Image(systemName: "chevron.right")
            }
            .disabled(isNextMonthInFuture)
            
            Spacer()
        }
        .padding(.top, 30)
        .padding(.horizontal, 32)
    }
}

// MARK: - Recap Card

struct RecapCard: View {
    let displayedDistance: String
    let displayedFuelUsed: String
    let displayedFuelCost: String
    let displayedAverage: String
    let comparisonText: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            RecapRow(title: NSLocalizedString("km_driven", comment: "Kilometers driven"), value: displayedDistance)
            RecapRow(title: NSLocalizedString("total_fuel_used", comment: "Total fuel used"), value: displayedFuelUsed)
            RecapRow(title: NSLocalizedString("total_fuel_cost", comment: "Total fuel cost"), value: displayedFuelCost)
            RecapRow(title: NSLocalizedString("average_fuel_usage", comment: "Average fuel usage"), value: displayedAverage)
            if let comparison = comparisonText {
                RecapRow(title: NSLocalizedString("comparison", comment: "Compared to previous month"), value: comparison)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

// MARK: - Recap Row

struct RecapRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(.orange)
        }
    }
}
