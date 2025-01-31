//
//  MaintenanceView.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/01/2025.
//

import SwiftUI

struct MaintenanceView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAddMaintenanceSheet: Bool
    var isVehicleActive: Bool
    @State private var showAllMaintenanceEntries = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(NSLocalizedString("maintenance_title", comment: ""))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showAddMaintenanceSheet = true
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
                    MaintenanceListView(viewModel: viewModel, showAddMaintenanceSheet: $showAddMaintenanceSheet)
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
        .sheet(isPresented: $showAllMaintenanceEntries) {
            AllMaintenanceView(viewModel: viewModel)
        }
    }
}

struct MaintenanceListView: View {
    @ObservedObject var viewModel: VehicleViewModel
    @Binding var showAddMaintenanceSheet: Bool
    @State private var showAllMaintenanceEntries = false
    
    var body: some View {
        if let maintenances = viewModel.activeVehicle?.maintenances.sorted(by: { $0.date > $1.date }), !maintenances.isEmpty {
            let latestEntries = Array(maintenances.prefix(3))
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(latestEntries, id: \.self) { maintenance in
                    MaintenanceRow(maintenance: maintenance)
                }
                
                if maintenances.count > 3 {
                    Button(action: {
                        showAllMaintenanceEntries = true
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
            Text(NSLocalizedString("maintenance_no_content", comment: ""))
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}


struct MaintenanceRow: View {
    @State var maintenance: Maintenance
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(maintenance.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text("\(maintenance.type.rawValue): €\(maintenance.cost, specifier: "%.2f")")
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let notes = maintenance.notes {
                    Text(notes)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: maintenanceIcon(for: maintenance.type))
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private func maintenanceIcon(for type: MaintenanceType) -> String {
        switch type {
        case .tires:
            return "tire"
        case .distributionBelt:
            return "gearshape.circle"
        case .oilChange:
            return "oilcan.fill"
        case .brakes:
            return "exclamationmark.brakesignal"
        case .other:
            return "wrench.and.screwdriver.fill"
        }
    }
}
