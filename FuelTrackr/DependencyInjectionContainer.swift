// MARK: - Package: App

//
//  DIContainer.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 30/04/2025.
//

import Factory
import SwiftData
import Domain
import Data
import Presentation

public extension Container {
    // MARK: - Core
    
    var modelContext: Factory<ModelContext> {
        self { fatalError("ModelContext must be registered at runtime") }
    }
    
    // MARK: - Repositories
    
    var vehicleRepository: Factory<VehicleRepositoryProtocol> {
        self { VehicleRepository(context: self.modelContext()) }
    }
    
    var settingsRepository: Factory<SettingsRepositoryProtocol> {
        self { SettingsRepository() }
    }
    
    // MARK: - Use Cases: Vehicle
    
    var loadActiveVehicleUseCase: Factory<LoadActiveVehicleUseCase> {
        self { LoadActiveVehicleUseCase(repository: self.vehicleRepository()) }
    }
    
    var saveVehicleUseCase: Factory<SaveVehicleUseCase> {
        self { SaveVehicleUseCase(repository: self.vehicleRepository()) }
    }
    
    var updateVehicleUseCase: Factory<UpdateVehicleUseCase> {
        self { UpdateVehicleUseCase(repository: self.vehicleRepository()) }
    }
    
    var deleteVehicleUseCase: Factory<DeleteVehicleUseCase> {
        self { DeleteVehicleUseCase(repository: self.vehicleRepository()) }
    }
    
    var saveFuelUsageUseCase: Factory<SaveFuelUsageUseCase> {
        self { SaveFuelUsageUseCase(repository: self.vehicleRepository()) }
    }
    
    var deleteFuelUsageUseCase: Factory<DeleteFuelUsageUseCase> {
        self { DeleteFuelUsageUseCase(repository: self.vehicleRepository()) }
    }
    
    var resetFuelUsageUseCase: Factory<ResetFuelUsageUseCase> {
        self { ResetFuelUsageUseCase(repository: self.vehicleRepository()) }
    }
    
    var saveMaintenanceUseCase: Factory<SaveMaintenanceUseCase> {
        self { SaveMaintenanceUseCase(repository: self.vehicleRepository()) }
    }
    
    var deleteMaintenanceUseCase: Factory<DeleteMaintenanceUseCase> {
        self { DeleteMaintenanceUseCase(repository: self.vehicleRepository()) }
    }
    
    var resetMaintenanceUseCase: Factory<ResetMaintenanceUseCase> {
        self { ResetMaintenanceUseCase(repository: self.vehicleRepository()) }
    }
    
    var updatePurchaseStatusUseCase: Factory<UpdateVehiclePurchaseStatusUseCase> {
        self { UpdateVehiclePurchaseStatusUseCase(repository: self.vehicleRepository()) }
    }
    
    var migrateVehiclesUseCase: Factory<MigrateVehiclesUseCase> {
        self { MigrateVehiclesUseCase(repository: self.vehicleRepository()) }
    }
    
    var getFuelUsedUseCase: Factory<GetFuelUsedUseCase> {
        self { GetFuelUsedUseCase(repository: self.vehicleRepository()) }
    }
    
    var getFuelCostUseCase: Factory<GetFuelCostUseCase> {
        self { GetFuelCostUseCase(repository: self.vehicleRepository()) }
    }
    
    var getKmDrivenUseCase: Factory<GetKmDrivenUseCase> {
        self { GetKmDrivenUseCase(repository: self.vehicleRepository()) }
    }
    
    var getAverageFuelUsageUseCase: Factory<GetAverageFuelUsageUseCase> {
        self { GetAverageFuelUsageUseCase(repository: self.vehicleRepository()) }
    }
    
    // MARK: - Use Cases: Settings
    
    var getIsNotificationsEnabledUseCase: Factory<GetNotificationsEnabledUseCase> {
        self { GetNotificationsEnabledUseCase(repository: self.settingsRepository()) }
    }
    
    var setIsNotificationsEnabledUseCase: Factory<SetNotificationsEnabledUseCase> {
        self { SetNotificationsEnabledUseCase(repository: self.settingsRepository()) }
    }
    
    var getUsingMetricUseCase: Factory<GetUsingMetricUseCase> {
        self { GetUsingMetricUseCase(repository: self.settingsRepository()) }
    }
    
    var setUsingMetricUseCase: Factory<SetUsingMetricUseCase> {
        self { SetUsingMetricUseCase(repository: self.settingsRepository()) }
    }
    
    var getDefaultTireIntervalUseCase: Factory<GetDefaultTireIntervalUseCase> {
        self { GetDefaultTireIntervalUseCase(repository: self.settingsRepository()) }
    }
    
    var setDefaultTireIntervalUseCase: Factory<SetDefaultTireIntervalUseCase> {
        self { SetDefaultTireIntervalUseCase(repository: self.settingsRepository()) }
    }
    
    var getDefaultOilChangeIntervalUseCase: Factory<GetDefaultOilChangeIntervalUseCase> {
        self { GetDefaultOilChangeIntervalUseCase(repository: self.settingsRepository()) }
    }
    
    var setDefaultOilChangeIntervalUseCase: Factory<SetDefaultOilChangeIntervalUseCase> {
        self { SetDefaultOilChangeIntervalUseCase(repository: self.settingsRepository()) }
    }
    
    var getDefaultBrakeCheckIntervalUseCase: Factory<GetDefaultBrakeCheckIntervalUseCase> {
        self { GetDefaultBrakeCheckIntervalUseCase(repository: self.settingsRepository()) }
    }
    
    var setDefaultBrakeCheckIntervalUseCase: Factory<SetDefaultBrakeCheckIntervalUseCase> {
        self { SetDefaultBrakeCheckIntervalUseCase(repository: self.settingsRepository()) }
    }
    
    var getSelectedCurrencyUseCase: Factory<GetSelectedCurrencyUseCase> {
        self { GetSelectedCurrencyUseCase(repository: self.settingsRepository()) }
    }
    
    var setSelectedCurrencyUseCase: Factory<SetSelectedCurrencyUseCase> {
        self { SetSelectedCurrencyUseCase(repository: self.settingsRepository()) }
    }
    
    // MARK: - ViewModels
    
    var vehicleViewModel: Factory<VehicleViewModel> {
        self {
            VehicleViewModel(
                loadActiveVehicleUseCase: self.loadActiveVehicleUseCase(),
                saveVehicleUseCase: self.saveVehicleUseCase(),
                updateVehicleUseCase: self.updateVehicleUseCase(),
                deleteVehicleUseCase: self.deleteVehicleUseCase(),
                saveFuelUsageUseCase: self.saveFuelUsageUseCase(),
                deleteFuelUsageUseCase: self.deleteFuelUsageUseCase(),
                resetFuelUsageUseCase: self.resetFuelUsageUseCase(),
                saveMaintenanceUseCase: self.saveMaintenanceUseCase(),
                deleteMaintenanceUseCase: self.deleteMaintenanceUseCase(),
                resetMaintenanceUseCase: self.resetMaintenanceUseCase(),
                updateVehiclePurchaseStatusUseCase: self.updatePurchaseStatusUseCase(),
                migrateVehiclesUseCase: self.migrateVehiclesUseCase(),
                getFuelUsedUseCase: self.getFuelUsedUseCase(),
                getFuelCostUseCase: self.getFuelCostUseCase(),
                getKmDrivenUseCase: self.getKmDrivenUseCase(),
                getAverageFuelUsageUseCase: self.getAverageFuelUsageUseCase(),
                getUsingMetricUseCase: self.getUsingMetricUseCase()
            )
        }
    }
    
    var settingsViewModel: Factory<SettingsViewModel> {
        self {
            SettingsViewModel(
                getIsNotificationsEnabled: self.getIsNotificationsEnabledUseCase(),
                setIsNotificationsEnabled: self.setIsNotificationsEnabledUseCase(),
                getIsUsingMetric: self.getUsingMetricUseCase(),
                setIsUsingMetric: self.setUsingMetricUseCase(),
                getDefaultTireInterval: self.getDefaultTireIntervalUseCase(),
                setDefaultTireInterval: self.setDefaultTireIntervalUseCase(),
                getDefaultOilChangeInterval: self.getDefaultOilChangeIntervalUseCase(),
                setDefaultOilChangeInterval: self.setDefaultOilChangeIntervalUseCase(),
                getDefaultBrakeCheckInterval: self.getDefaultBrakeCheckIntervalUseCase(),
                setDefaultBrakeCheckInterval: self.setDefaultBrakeCheckIntervalUseCase(),
                getSelectedCurrency: self.getSelectedCurrencyUseCase(),
                setSelectedCurrency: self.setSelectedCurrencyUseCase()
            )
        }
    }
    
    var addFuelUsageViewModel: Factory<AddFuelUsageViewModel> {
        self {
            AddFuelUsageViewModel(
                saveFuelUsageUseCase: self.saveFuelUsageUseCase(),
                getUsingMetricUseCase: self.getUsingMetricUseCase()
            )
        }
    }
    
    // MARK: - Managers
    
//    var notificationManager: Factory<NotificationManagerProtocol> {
//        self { NotificationManager(settingsRepository: self.settingsRepository()) }
//    }
}
