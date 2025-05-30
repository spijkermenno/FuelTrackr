// MARK: - Package: Presentation

//
//  ToggleSettingsView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 01/05/2025.
//

import SwiftUI
import Domain


public struct ToggleSettingsView: View {
    public var viewModel = SettingsViewModel()

    public var body: some View {
        VStack(spacing: 12) {
            Toggle(
                NSLocalizedString("use_metric_units", comment: "Toggle for using metric units"),
                isOn: Binding(
                    get: { viewModel.isUsingMetric },
                    set: { newValue in viewModel.updateMetricSystem(newValue) }
                )
            )
            .toggleStyle(SwitchToggleStyle(tint: .orange))

            Toggle(
                NSLocalizedString("use_imperial_units", comment: "Toggle for using imperial units"),
                isOn: Binding(
                    get: { !viewModel.isUsingMetric },
                    set: { newValue in viewModel.updateMetricSystem(!newValue) }
                )
            )
            .toggleStyle(SwitchToggleStyle(tint: .orange))
        }
        .padding()
    }
}
