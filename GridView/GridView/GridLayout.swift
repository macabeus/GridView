//
//  GridLayout.swift
//  GridView
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit

protocol GridLayoutDelegate {
    
    var gridConfiguration: GridConfiguration { get }
}

public class GridLayout: UICollectionViewLayout {
    
    var delegate: GridLayoutDelegate!
    
    var cellPadding: CGFloat = 6.0
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat  = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    public var numberOfColumns: Int {
        return delegate.gridConfiguration.gridNumberOfColumns
    }
    
    public var numberOfRows: Int {
        return delegate.gridConfiguration.gridNumberOfRows
    }
    
    public var columnWidth: CGFloat {
        return contentWidth / CGFloat(numberOfColumns)
    }
    
    public var columnRow: CGFloat {
        return (collectionView!.bounds.height / CGFloat(numberOfRows)) - cellPadding * CGFloat(numberOfRows)
    }
    
    override public func prepare() {
        
        if cache.isEmpty {
            // initialize variables with the dimensions
            var xOffset = [CGFloat]()
            for column in 0..<numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth)
            }
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            //
            var indexPathSection = -1
            var indexPathItem = 0
            var yOffsetMiniumForNewRow: CGFloat = 0
            for i in delegate.gridConfiguration.parseSlotStep {
                
                switch i {
                    
                case .cell(let row, let column):
                    indexPathSection += 1
                    
                    // set size of cell
                    let slotSize = delegate.gridConfiguration.cellSlotSize(section: row, row: indexPathSection)
                    let slotWidth = slotSize.width
                    let slotHeight = slotSize.height
                    
                    let cellWidth = CGFloat(slotWidth) * columnWidth
                    let cellHeight = CGFloat(slotHeight) * columnRow
                    var height = cellHeight + cellPadding
                    if slotHeight > 1 { // se a célula ocupa mais que um slot horizontal, acrescentar à célula o espaço de padding
                        height += CGFloat(slotHeight) * cellPadding
                    }
                    
                    // desenhar o frame da célula e adicioná-la ao cache
                    let frame = CGRect(x: xOffset[column], y: yOffset[column], width: cellWidth, height: height)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    
                    let indexPath = IndexPath(item: indexPathSection, section: indexPathItem)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cache.append(attributes)
                    
                    //
                    for i in 0..<slotWidth {
                        yOffset[column + i] = yOffset[column + i] + height + cellPadding
                    }
                
                case .newRow():
                    // update yOffset of slots that not receive a cell
                    yOffsetMiniumForNewRow += columnRow + cellPadding * 2
                    yOffset = yOffset.map { max(yOffsetMiniumForNewRow, $0) }
                    
                    //
                    indexPathSection = -1
                    indexPathItem += 1
                }
            }
        }
    }
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    func clearCache() {
        self.cache = []
    }
    
}
