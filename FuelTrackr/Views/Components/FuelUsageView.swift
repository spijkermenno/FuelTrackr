//
//  FuelUsageView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

struct FuelUsageView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAddFuelSheet: Bool
    var isVehicleActive: Bool
    @State private var showAllFuelEntries = false
    @State private var selectedTab = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(NSLocalizedString("fuel_usage_title", comment: ""))
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    showAddFuelSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(NSLocalizedString("add", comment: ""))
                    }
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isVehicleActive ? Color.blue : Color.gray.opacity(0.5))
                    .cornerRadius(8)
                }
                .disabled(!isVehicleActive)
            }

            VStack(spacing: 8) {
                TabView(selection: $selectedTab) {
                    FuelUsageListView(viewModel: viewModel, showAllFuelEntries: $showAllFuelEntries)
                        .tag(0)

                    Text(NSLocalizedString("no_graph", comment: ""))
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(minHeight: 100)

                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 0 ? .blue : .gray)

                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(selectedTab == 1 ? .blue : .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .sheet(isPresented: $showAllFuelEntries) {
            AllFuelUsageView(viewModel: viewModel)
        }
    }
}

struct FuelUsageListView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAllFuelEntries: Bool

    var body: some View {
        if let fuelUsages = viewModel.activeVehicle?.fuelUsages.sorted(by: { $0.date > $1.date }), !fuelUsages.isEmpty {
            let latestEntries = Array(fuelUsages.prefix(3))

            VStack(alignment: .leading, spacing: 12) {
                ForEach(latestEntries, id: \.self) { usage in
                    FuelUsageRow(usage: usage)
                }

                if fuelUsages.count > 3 {
                    Button(action: {
                        showAllFuelEntries = true
                    }) {
                        Text(NSLocalizedString("show_more", comment: ""))
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
            }
        } else {
            Text(NSLocalizedString("fuel_usage_no_content", comment: ""))
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct FuelUsageRow: View {
    let usage: FuelUsage

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(usage.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Text("\(usage.liters, specifier: "%.2f") liters, €\(usage.cost, specifier: "%.2f")")
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
            if usage.liters > 0 {
                Text("€\(usage.cost / usage.liters, specifier: "%.2f")/L")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
