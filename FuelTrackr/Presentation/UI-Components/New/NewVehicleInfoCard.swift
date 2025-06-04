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
                }
                .padding(.horizontal)
            },
            content: {
                VStack {
                    SingleRow(title: "Kilometerstand", value: "\(mileage.formattedWithSeparator) km")
                    
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
                .fontWeight(Font.Weight.regular)
                .font(.system(size: 15))
                .foregroundStyle(Theme.colors.onSurface)
            
            Spacer()
            
            Text(value)
                .fontWeight(Font.Weight.regular)
                .font(.system(size: 15))
                .foregroundStyle(Color.black)
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
                    .fontWeight(Font.Weight.regular)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.colors.onSurface)
                
                Spacer()
                
                Text(firstValue)
                    .fontWeight(Font.Weight.regular)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.black)
            }
            
            HStack {
                Spacer()
                
                Text(secondValue)
                    .fontWeight(Font.Weight.regular)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.colors.primary)
            }
        }
        .padding(8)
    }
}

struct CircleIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.colors.purple)
                .frame(width: 50, height: 50)
            
            Image(systemName: "car.fill")
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .medium))
        }
    }
}

#Preview {
    NewVehicleInfoCard(
        licensePlate: "12345",
        mileage: 1,
        purchaseDate: Date(),
        productionDate: Date()
    )
}
