// MARK: - Dependency Injection
//
//  GetDefaultBrakeCheckIntervalUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/05/2025.
//

import Domain
import Data

extension GetDefaultBrakeCheckIntervalUseCase {
    public init() {
        self.init(repository: SettingsRepository())
    }
}
