//
//  AddFuelUsageViewModelFactory.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/04/2025.
//

import SwiftData
import Foundation

struct AddFuelUsageViewModelFactory {
    static func make(context: ModelContext) -> AddFuelUsageViewModel {
        let vehicleRepository = VehicleRepositoryImpl(context: context)
        let saveFuelUsageUseCase = SaveFuelUsageUseCase(repository: vehicleRepository)

        let settingsRepository = SettingsRepositoryImpl()
        let isUsingMetric = GetUsingMetricUseCase(repository: settingsRepository).execute()

        return AddFuelUsageViewModel(
            saveFuelUsageUseCase: saveFuelUsageUseCase,
            isUsingMetric: isUsingMetric
        )
    }
}
