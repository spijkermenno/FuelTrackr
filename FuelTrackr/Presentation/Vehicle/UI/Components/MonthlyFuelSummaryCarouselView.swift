//
//  MonthlyFuelSummaryCarouselView.swift
//  FuelTrackr
//
//  Carousel displaying monthly fuel summaries using the same style as VehicleStatisticsCarouselView
//

import SwiftUI
import Domain
import SwiftData

struct MonthlySummaryCustomPagingBehavior: ScrollTargetBehavior {
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

public struct MonthlyFuelSummaryCarouselView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var context
    
    let vehicleViewModel: VehicleViewModel
    let isUsingMetric: Bool
    
    private let spacing: CGFloat = 16
    @State private var currentIndex: Int? = 0
    
    // Get summaries - now cached in ViewModel to prevent repeated calculations
    private var summaries: [MonthlyFuelSummaryUiModel] {
        vehicleViewModel.monthlyFuelSummaries(context: context)
    }
    
    public var body: some View {
        if summaries.isEmpty {
            EmptyView()
        } else {
            GeometryReader { geometry in
                let containerWidth = geometry.size.width
                let cardWidth = containerWidth * 0.9
                let pageWidth = cardWidth + spacing
                let sideGutter = (containerWidth - pageWidth) / 2

                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Array(summaries.enumerated()), id: \.element.id) { index, summary in
                                GeometryReader { itemGeo in
                                    let scale = scaleValue(container: geometry, item: itemGeo)
                                    let opacity = opacityValue(container: geometry, item: itemGeo)

                                    MonthlyFuelSummaryCard(
                                        summary: summary,
                                        isUsingMetric: isUsingMetric
                                    )
                                    .frame(width: cardWidth, height: 210)
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
                    .scrollTargetBehavior(MonthlySummaryCustomPagingBehavior(pageWidth: pageWidth))
                    .animation(.interactiveSpring(response: 0.20, dampingFraction: 0.85, blendDuration: 0), value: currentIndex)
                    .scrollPosition(id: $currentIndex)
                    .frame(height: 210)

                    MonthlySummaryPageControl(numberOfPages: summaries.count, currentPage: currentIndex ?? 0)
                }
                .padding(.top, 10)
            }
            .frame(height: 244)
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

struct MonthlySummaryPageControl: View {
    public static let Height: CGFloat = 24
    
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
        .frame(height: MonthlySummaryPageControl.Height)
    }
}

