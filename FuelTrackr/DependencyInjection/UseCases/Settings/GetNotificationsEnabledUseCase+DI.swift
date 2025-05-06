// MARK: - Dependency Injection
//
//  GetNotificationsEnabledUseCase+DI.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 03/05/2025.
//

import Domain
import Data

extension GetNotificationsEnabledUseCase {
    public init() {
        self.init(repository: SettingsRepository())
    }
}
