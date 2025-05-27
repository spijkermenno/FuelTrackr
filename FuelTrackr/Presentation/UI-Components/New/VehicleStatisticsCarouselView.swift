//
//  Carousel.swift
//  FuelTrackr
//
//  Created by Menno Spijker on 27/05/2025.
//

import SwiftUI

struct CustomPagingBehavior: ScrollTargetBehavior {
    let pageWidth: CGFloat

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let container = context.containerSize.width
        guard container > 0 else { return }

        let velocity = context.velocity.dx
        var offset = target.rect.minX
        let threshold: CGFloat = 500

        let index: CGFloat
        if velocity > threshold {
            index = ceil((offset + container) / pageWidth)
        } else if velocity < -threshold {
            index = floor((offset - container) / pageWidth)
        } else {
            index = round(offset / pageWidth)
        }

        offset = index * pageWidth
        offset = min(max(0, offset), context.contentSize.width - container)
        target.rect.origin.x = offset
    }
}

struct VehicleStatisticsCarouselView: View {
    let items: [VehicleStatisticsUiModel]

    private let spacing: CGFloat = 16
    @State private var currentIndex: Int? = 0

    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            let cardWidth = containerWidth * 0.9
            let pageWidth = cardWidth + spacing
            let sideGutter = (containerWidth - pageWidth) / 2

            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            GeometryReader { itemGeo in
                                let scale   = scaleValue(container: geometry, item: itemGeo)
                                let opacity = opacityValue(container: geometry, item: itemGeo)

                                VehicleStatisticCardView(uiModel: item)
                                    .frame(width: cardWidth)
                                    .padding(.horizontal, spacing / 2)
                                    .scaleEffect(scale)
                                    .opacity(opacity)
                                    .id(index)
                            }
                            .frame(width: pageWidth)
                            .scrollTargetLayout()
                        }
                    }
                }
                .contentMargins(.horizontal, sideGutter, for: .scrollContent)
                .scrollTargetBehavior(CustomPagingBehavior(pageWidth: pageWidth))
                .animation(.interactiveSpring(response: 0.20, dampingFraction: 0.85, blendDuration: 0), value: currentIndex)
                .scrollPosition(id: $currentIndex)
                .frame(height: 203)

                PageControl(numberOfPages: items.count, currentPage: currentIndex ?? 0)
            }
        }
    }

    private func scaleValue(container: GeometryProxy, item: GeometryProxy) -> CGFloat {
        let centre = container.frame(in: .global).midX
        let itemCentre = item.frame(in: .global).midX
        let distance = abs(centre - itemCentre)
        let maxDistance: CGFloat = 200
        return max(0.9, 1 - (distance / maxDistance) * 0.1)
    }

    private func opacityValue(container: GeometryProxy, item: GeometryProxy) -> Double {
        let centre = container.frame(in: .global).midX
        let itemCentre = item.frame(in: .global).midX
        let distance = abs(centre - itemCentre)
        let maxDistance: CGFloat = 200
        return max(0.5, 1 - (distance / maxDistance) * 0.5)
    }
}

struct PageControl: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Theme.colors.primary : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.top, 2)
        .padding(.bottom)
    }
}

#Preview {
    VehicleStatisticsCarouselView(items: mock)
        .background(Color.gray.opacity(0.1))
}

struct VehicleStatisticsUiModel: Identifiable {
    var id: UUID = UUID()
    var period: Period
    var distanceDriven: Double
    var fuelUsed: Double
    var totalCost: Double
}

enum Period {
    case CurrentMonth
    case LastMonth
    case YTD
    case AllTime
}

private let mock = [
    VehicleStatisticsUiModel(period: Period.CurrentMonth, distanceDriven: 1230, fuelUsed: 84.3, totalCost: 123.2),
    VehicleStatisticsUiModel(period: Period.LastMonth, distanceDriven: 2130, fuelUsed: 834.3, totalCost: 1233.2),
    VehicleStatisticsUiModel(period: Period.YTD, distanceDriven: 12350, fuelUsed: 184.3, totalCost: 523.2),
    VehicleStatisticsUiModel(period: Period.AllTime, distanceDriven: 1230, fuelUsed: 84.3, totalCost: 123.2),
]
