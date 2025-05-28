// MARK: - Dependency Injection
//
//  SetDefaultTireIntervalUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/05/2025.
//

import Domain
import Data

extension SetDefaultTireIntervalUseCase {
    public init() {
        self.init(repository: SettingsRepository())
    }
}
