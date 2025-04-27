//
//  MonthlyRecapViewModelFactory.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import Foundation
import SwiftData

struct MonthlyRecapViewModelFactory {
    static func make(context: ModelContext) -> MonthlyRecapViewModel {
        let vehicleRepository = VehicleRepositoryImpl(context: context)
        let settingsRepository = SettingsRepositoryImpl()

        return MonthlyRecapViewModel(
            getFuelUsedUseCase: GetFuelUsedUseCase(repository: vehicleRepository),
            getFuelCostUseCase: GetFuelCostUseCase(repository: vehicleRepository),
            getKmDrivenUseCase: GetKmDrivenUseCase(repository: vehicleRepository),
            getAverageFuelUsageUseCase: GetAverageFuelUsageUseCase(repository: vehicleRepository),
            getUsingMetricUseCase: GetUsingMetricUseCase(repository: settingsRepository)
        )
    }
}
