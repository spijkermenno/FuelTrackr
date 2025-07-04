//
//  LabeledToggleView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 04/07/2025.
//

import SwiftUI

public struct LabeledToggleView: View {
    public let title: String
    @Binding public var isOn: Bool
    public let description: String?
    public let tint: Color

    public init(
        title: String,
        isOn: Binding<Bool>,
        description: String? = nil,
        tint: Color = Theme.colors.purple
    ) {
        self.title = title
        self._isOn = isOn
        self.description = description
        self.tint = tint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(title, isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: tint))

            if let description = description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
