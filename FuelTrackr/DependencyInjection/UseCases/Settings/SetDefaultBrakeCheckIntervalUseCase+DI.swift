// MARK: - Dependency Injection
//
//  SetDefaultBrakeCheckIntervalUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/05/2025.
//

import Domain
import Data

extension SetDefaultBrakeCheckIntervalUseCase {
    public init() {
        self.init(repository: SettingsRepository())
    }
}
