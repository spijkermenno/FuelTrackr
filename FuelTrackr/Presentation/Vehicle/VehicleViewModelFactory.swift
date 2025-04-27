//
//  VehicleViewModelFactory.swift
//

import SwiftData
import Foundation
import SwiftUI

struct VehicleViewModelFactory {
    static func make(context: ModelContext) -> VehicleViewModel {
        let repository = VehicleRepositoryImpl(context: context)
        let settingsRepository = SettingsRepositoryImpl()

        return VehicleViewModel(
            loadActiveVehicleUseCase: LoadActiveVehicleUseCase(repository: repository),
            saveVehicleUseCase: SaveVehicleUseCase(repository: repository),
            updateVehicleUseCase: UpdateVehicleUseCase(repository: repository),
            deleteVehicleUseCase: DeleteVehicleUseCase(repository: repository),
            saveFuelUsageUseCase: SaveFuelUsageUseCase(repository: repository),
            deleteFuelUsageUseCase: DeleteFuelUsageUseCase(repository: repository),
            resetFuelUsageUseCase: ResetFuelUsageUseCase(repository: repository),
            saveMaintenanceUseCase: SaveMaintenanceUseCase(repository: repository),
            deleteMaintenanceUseCase: DeleteMaintenanceUseCase(repository: repository),
            resetMaintenanceUseCase: ResetMaintenanceUseCase(repository: repository),
            updateVehiclePurchaseStatusUseCase: UpdateVehiclePurchaseStatusUseCase(repository: repository),
            migrateVehiclesUseCase: MigrateVehiclesUseCase(repository: repository),
            getFuelUsedUseCase: GetFuelUsedUseCase(repository: repository),
            getFuelCostUseCase: GetFuelCostUseCase(repository: repository),
            getKmDrivenUseCase: GetKmDrivenUseCase(repository: repository),
            getAverageFuelUsageUseCase: GetAverageFuelUsageUseCase(repository: repository),
            getUsingMetricUseCase: GetUsingMetricUseCase(repository: settingsRepository)
        )
    }
}
