// MARK: - Dependency Injection
//
//  GetUsingMetricUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/05/2025.
//

import Domain
import Data

extension GetUsingMetricUseCase {
    public init() {
        self.init(repository: SettingsRepository())
    }
}
