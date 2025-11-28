//
//  VehicleInfoCard.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 04/05/2025.
//

import SwiftUI

struct NewVehicleInfoCard: View {
    let licensePlate: String
    let mileage: Int
    let purchaseDate: Date
    let productionDate: Date
    
    var body: some View {
        Card(
            header: {
                HStack(spacing: 10) {
                    CircleIconView()
                    
                    Text(licensePlate)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal)
            },
            content: {
                VStack {
                    SingleRow(
                        title: "Kilometerstand",
                        value: "\(mileage.formattedWithSeparator) km"
                    )
                    
                    DoubleRow(
                        title: "Aankoopdatum",
                        firstValue: purchaseDate.formatted(date: .long, time: .omitted),
                        secondValue: purchaseDate.relativeDescription()
                    )
                    
                    DoubleRow(
                        title: "Productiedatum",
                        firstValue: productionDate.formatted(date: .long, time: .omitted),
                        secondValue: productionDate.relativeDescription()
                    )
                }
                .frame(maxWidth: .infinity)
            }
        )
    }
}

private struct SingleRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
        }
        .padding(8)
    }
}

private struct DoubleRow: View {
    let title: String
    let firstValue: String
    let secondValue: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(firstValue)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
            }
            
            HStack {
                Spacer()
                
                Text(secondValue)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
    }
}

struct CircleIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.blue)
                .frame(width: 50, height: 50)
            
            Image(systemName: "car.fill")
                .foregroundStyle(.white)
                .font(.system(size: 24, weight: .medium))
        }
    }
}
