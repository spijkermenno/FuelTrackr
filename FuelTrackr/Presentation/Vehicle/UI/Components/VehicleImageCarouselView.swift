//
//  VehicleImageCarouselView.swift
//  FuelTrackr
//
//  Vehicle carousel component with image and details card using the same carousel style
//

import SwiftUI
import UIKit
import Domain

struct VehicleImageCustomPagingBehavior: ScrollTargetBehavior {
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

public struct VehicleImageCarouselView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let photoData: Data?
    let licensePlate: String
    let currentMileage: Int
    let purchaseDate: Date
    let productionDate: Date
    let isUsingMetric: Bool
    
    private let spacing: CGFloat = 16
    @State private var currentIndex: Int? = 0
    
    private var colors: ColorsProtocol {
        Theme.colors(for: colorScheme)
    }
    
    // Carousel has 2 items: image and details card
    private let numberOfPages = 2
    
    private var items: [CarouselItem] {
        var items: [CarouselItem] = []
        
        // Item 0: Vehicle Image
        items.append(.image(photoData))
        
        // Item 1: Vehicle Details Card
        items.append(.details(
            licensePlate: licensePlate,
            currentMileage: currentMileage,
            purchaseDate: purchaseDate,
            productionDate: productionDate,
            isUsingMetric: isUsingMetric
        ))
        
        return items
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            let cardWidth = containerWidth * 0.9
            let pageWidth = cardWidth + spacing
            let sideGutter = (containerWidth - pageWidth) / 2

            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                            GeometryReader { itemGeo in
                                let scale = scaleValue(container: geometry, item: itemGeo)
                                let opacity = opacityValue(container: geometry, item: itemGeo)

                                Group {
                                    switch item {
                                    case .image(let data):
                                        if let data = data, let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 190)
                                                .frame(maxWidth: .infinity)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 31))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 31)
                                                        .stroke(colors.border, lineWidth: 1)
                                                )
                                        }
                                    case .details(let licensePlate, let currentMileage, let purchaseDate, let productionDate, let isUsingMetric):
                                        VehicleDetailsCard(
                                            licensePlate: licensePlate,
                                            currentMileage: currentMileage,
                                            purchaseDate: purchaseDate,
                                            productionDate: productionDate,
                                            isUsingMetric: isUsingMetric
                                        )
                                    }
                                }
                                .frame(width: cardWidth)
                                .padding(.horizontal, spacing / 2)
                                .padding(.vertical, 10)
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
                .scrollTargetBehavior(VehicleImageCustomPagingBehavior(pageWidth: pageWidth))
                .animation(.interactiveSpring(response: 0.20, dampingFraction: 0.85, blendDuration: 0), value: currentIndex)
                .scrollPosition(id: $currentIndex)
                .frame(height: 210)

                VehicleImagePageControl(numberOfPages: numberOfPages, currentPage: currentIndex ?? 0)
            }
            .padding(.top, 10)
        }
        .frame(height: 244)
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

private enum CarouselItem {
    case image(Data?)
    case details(licensePlate: String, currentMileage: Int, purchaseDate: Date, productionDate: Date, isUsingMetric: Bool)
}

struct VehicleImagePageControl: View {
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
        .frame(height: VehicleImagePageControl.Height)
    }
}
