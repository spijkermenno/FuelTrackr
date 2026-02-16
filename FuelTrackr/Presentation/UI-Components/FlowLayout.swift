//
//  FlowLayout.swift
//  FuelTrackr
//
//  Flow layout that arranges items in rows, wrapping to next line when needed
//  Similar to UICollectionViewFlowLayout behavior
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8
    
    init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let availableWidth = proposal.width ?? .infinity
        let rows = arrangeSubviews(subviews: subviews, in: CGRect(x: 0, y: 0, width: availableWidth, height: .infinity))
        let totalHeight = rows.reduce(0) { $0 + $1.height } + lineSpacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: availableWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(subviews: subviews, in: bounds)
        
        var y = bounds.minY
        for row in rows {
            let rowHeight = row.height
            let totalRowWidth = row.items.reduce(0) { $0 + $1.width } + spacing * CGFloat(max(0, row.items.count - 1))
            let rowStartX = bounds.minX
            
            var x = rowStartX
            for item in row.items {
                item.subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: item.width, height: item.height)
                )
                x += item.width + spacing
            }
            
            y += rowHeight + lineSpacing
        }
    }
    
    private struct Row {
        var items: [Item]
        var height: CGFloat {
            items.map { $0.height }.max() ?? 0
        }
    }
    
    private struct Item {
        let subview: LayoutSubviews.Element
        let width: CGFloat
        let height: CGFloat
    }
    
    private func arrangeSubviews(subviews: Subviews, in bounds: CGRect) -> [Row] {
        guard !subviews.isEmpty else { return [] }
        
        var rows: [Row] = []
        var currentRow: [Item] = []
        var currentRowWidth: CGFloat = 0
        let availableWidth = bounds.width
        
        for subview in subviews {
            let naturalSize = subview.sizeThatFits(.unspecified)
            let itemWidth = naturalSize.width
            let itemHeight = naturalSize.height
            
            let spacingNeeded = currentRow.isEmpty ? 0 : spacing
            let totalWidthWithItem = currentRowWidth + spacingNeeded + itemWidth
            
            if totalWidthWithItem <= availableWidth || currentRow.isEmpty {
                // Add to current row
                currentRow.append(Item(subview: subview, width: itemWidth, height: itemHeight))
                currentRowWidth = totalWidthWithItem
            } else {
                // Start new row
                if !currentRow.isEmpty {
                    rows.append(Row(items: currentRow))
                }
                currentRow = [Item(subview: subview, width: itemWidth, height: itemHeight)]
                currentRowWidth = itemWidth
            }
        }
        
        // Add the last row
        if !currentRow.isEmpty {
            rows.append(Row(items: currentRow))
        }
        
        // Keep items at their natural size - don't stretch them
        // This ensures consistent 8px spacing between items
        return rows
    }
}
