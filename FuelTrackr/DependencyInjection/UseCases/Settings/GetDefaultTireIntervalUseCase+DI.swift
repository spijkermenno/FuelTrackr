// MARK: - Dependency Injection
//
//  GetDefaultTireIntervalUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/05/2025.
//

import Domain
import Data

extension GetDefaultTireIntervalUseCase {
    public init() {
        self.init(repository: SettingsRepository())
    }
}
