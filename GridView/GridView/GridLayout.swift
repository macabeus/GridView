//
//  GridLayout.swift
//  GridView
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit

protocol GridLayoutDelegate {
    
    /**
     Return length of row with max length
     */
    func maxRow() -> Int
    
    /**
     Return the size of a cell
    */
    func cellSlotSize(section: Int, row: Int) -> (width: Int, height: Int)
    
    /**
     Return total number of rows
    */
    func gridNumberOfRows() -> Int

    /**
     Return total number of columns
     */
    func gridNumberOfColumns() -> Int
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
    
    override public func prepare() {
        let numberOfColumns = delegate.gridNumberOfColumns()
        let numberOfRows = delegate.gridNumberOfRows()
        
        if cache.isEmpty {
            // initialize variables with the dimensions
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            let columnRow = (collectionView!.bounds.height / CGFloat(numberOfRows)) - cellPadding * CGFloat(numberOfRows)
            var xOffset = [CGFloat]()
            for column in 0..<numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth)
            }
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            // fill the collection view
            var column: Int
            let totalColumns = delegate.maxRow()
            var columnsFill: Int
            for section in 0..<collectionView!.numberOfSections {
                column = 0
                columnsFill = 0
                
                if collectionView!.numberOfItems(inSection: section) > 0 {
                    // get the first column with free space
                    while yOffset[columnsFill] > CGFloat(Int(columnRow) * (section + 1)) {
                        columnsFill += 1
                    }
                    column = columnsFill
                } else {
                    // if the row don't have a cell
                    columnsFill = totalColumns
                }
                
                //
                for item in 0..<collectionView!.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    
                    // set size of cell
                    let slotSize = delegate.cellSlotSize(section: section, row: item)
                    let slotWidth = slotSize.width
                    let slotHeight = slotSize.height
                    
                    let cellWidth = CGFloat(slotWidth) * columnWidth
                    let cellHeight = CGFloat(slotHeight) * columnRow
                    var height = cellHeight + cellPadding
                    if slotHeight > 1 { // se a célula ocupa mais que um slot horizontal, acrescentar à célula o espaço de padding
                        height += CGFloat(slotHeight) * cellPadding
                    }
                    
                    //
                    columnsFill += slotWidth
                    
                    // checar se tem espaço nessa coluna; se não tiver, ir para o próximo espaço vago
                    while yOffset[column] > CGFloat(Int(columnRow) * (section + 1)) {
                        column += 1
                        columnsFill += 1
                        if column == numberOfColumns {
                            print("[WARNING GridLayout] Célula de \(section):\(item) ultrapassou os limites!")
                        }
                    }
                    
                    // desenhar o frame da célula e adicioná-la ao cache
                    let frame = CGRect(x: xOffset[column], y: yOffset[column], width: cellWidth, height: height)
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = insetFrame
                    cache.append(attributes)
                    
                    // atualizar yOffset e contentHeight
                    contentHeight = max(contentHeight, frame.maxY)
                    
                    for i in 0..<slotWidth {
                        yOffset[column + i] = yOffset[column + i] + height + cellPadding
                    }
                    column += slotWidth
                }
                
                // update yOffset of slots that not receive a cell
                yOffset = yOffset[0..<columnsFill] +
                          yOffset[columnsFill..<yOffset.count].map { $0 + columnRow + (cellPadding * 2) }
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
