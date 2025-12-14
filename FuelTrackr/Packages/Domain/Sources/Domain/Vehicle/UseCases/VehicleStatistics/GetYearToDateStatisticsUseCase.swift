import Foundation
import SwiftData

public struct GetYearToDateStatisticsUseCase {
    private let calc: VehicleStatisticsCalculator

    public init(
        repository: any VehicleRepositoryProtocol,
        calendar: Calendar = .current
    ) {
        calc = VehicleStatisticsCalculator(repository: repository, calendar: calendar)
    }

    public func callAsFunction(context: ModelContext) throws -> VehicleStatisticsUiModel {
        guard let vehicle = try calc.repository.loadActiveVehicle(context: context) else {
            return VehicleStatisticsUiModel(period: .YTD, distanceDriven: 0, fuelUsed: 0, totalCost: 0)
        }

        let now = Date()
        let year = calc.calendar.component(.year, from: now)
        let currentMonth = calc.calendar.component(.month, from: now)

        // Distance built from consecutive mileage deltas within the current year
        let yearMileages = vehicle.mileages
            .filter { calc.calendar.component(.year, from: $0.date) == year }
            .sorted { $0.date < $1.date }

        var distance = 0
        if yearMileages.count > 1 {
            for idx in 1..<yearMileages.count {
                distance += yearMileages[idx].value - yearMileages[idx - 1].value
            }
        }

        // Fuel and cost summed month by month up to the current month
        var fuel = 0.0
        var cost = 0.0
        for month in 1...currentMonth {
            fuel += calc.repository.getFuelUsed(forMonth: month, year: year, context: context)
            cost += calc.repository.getFuelCost(forMonth: month, year: year, context: context)
        }

        return VehicleStatisticsUiModel(
            period: .YTD,
            distanceDriven: Double(distance),
            fuelUsed: fuel,
            totalCost: cost
        )
    }
}
