//
//  GridConfiguration.swift
//  GridView
//
//  Created by Bruno Macabeus Aquino on 29/05/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

//import Foundation
import UIKit // todo: GridConfiguration need be agnostic to UIKit!

public class GridConfiguration {
    
    let slots: [[Slot]]
    let parseSlotStep: [ParseSlotStep]
    let gridNumberOfRows: Int
    let gridNumberOfColumns: Int
    let indexPathToRowColumn: [IndexPath: (row: CountableClosedRange<Int>, column: CountableClosedRange<Int>)]
    private let cellPerRow: [Int: [IndexPath]]
    private let cellPerColumn: [Int: [IndexPath]]
    var cellToIndexPath: [UICollectionViewCell: IndexPath] = [:]
    
    private init(slots: [[Slot]], parseSlotStep: [ParseSlotStep], gridNumberOfRows: Int, gridNumberOfColumns: Int, indexPathToRowColumn: [IndexPath: (row: CountableClosedRange<Int>, column: CountableClosedRange<Int>)], cellPerRow: [Int: [IndexPath]], cellPerColumn: [Int: [IndexPath]]) {
        
        self.slots = slots
        self.parseSlotStep = parseSlotStep
        self.gridNumberOfRows = gridNumberOfRows
        self.gridNumberOfColumns = gridNumberOfColumns
        self.indexPathToRowColumn = indexPathToRowColumn
        self.cellPerRow = cellPerRow
        self.cellPerColumn = cellPerColumn
    }
    
    public class func create(slots: [[Slot]]) -> GridConfiguration {

        ////
        // parse
        var results: [ParseSlotStep] = []
        var cellPerRow: [Int: [IndexPath]] = [:]
        var cellPerColumn: [Int: [IndexPath]] = [:]
        var indexPathToRowColumn: [IndexPath: (row: CountableClosedRange<Int>, column: CountableClosedRange<Int>)] = [:]
        
        let slotsFilleds = MatrixBool(initialWidth: 1, initialHeight: 1)
        
        // fill the collection view
        var indexPathSection = -1
        var indexPathItem = 0
        
        var column: Int
        var columnsFill: Int
        
        for section in 0..<slots.count {
            column = 0
            columnsFill = 0
            
            if section == slotsFilleds.matrix.count {
                slotsFilleds.growHeight(1)
            }
            
            if slots[section].count > 0 {
                // get the first column with free space
                while slotsFilleds.matrix[section][columnsFill] {
                    columnsFill += 1
                }
                column = columnsFill
            } else {
                // if the row don't have a cell
                columnsFill = slotsFilleds.matrix[0].count
            }
            
            //
            for item in 0..<slots[section].count {
                indexPathSection += 1
                
                // set size of cell
                let slotSize = cellSlotSize(slots: slots, section: section, row: item)
                let slotWidth = slotSize.width
                let slotHeight = slotSize.height
                
                // grow up slotsFilleds if need
                let diffW = slotsFilleds.matrix[0].count - column - slotWidth
                if diffW < 0 {
                    slotsFilleds.growWidth(diffW * -1)
                }
                
                let diffH = slotsFilleds.matrix.count - section - slotHeight
                if diffH < 0 {
                    slotsFilleds.growHeight(diffH * -1)
                }
                
                //
                columnsFill += slotWidth
                
                // checar se tem espaço nessa coluna; se não tiver, ir para o próximo espaço vago
                while slotsFilleds.matrix[section][column...column + slotWidth - 1].contains(true) {
                    column += 1
                    columnsFill += 1
                }
                
                // atualizar yOffset e contentHeight
                for i in 0..<slotHeight {
                    for j in 0..<slotWidth {
                        slotsFilleds.matrix[section + i][column + j] = true
                    }
                }
                
                //
                results.append(.cell(row: section, collumn: column))
                
                //
                let indexPath = IndexPath(item: indexPathSection, section: indexPathItem)
                for i in 0..<slotWidth {
                    let index = column + i
                    
                    cellPerColumn[index] = (cellPerColumn[index] ?? [])
                    cellPerColumn[index]!.append(indexPath)
                }
                
                for i in 0..<slotHeight {
                    let index = section + i
                    
                    cellPerRow[index] = (cellPerRow[index] ?? [])
                    cellPerRow[index]!.append(indexPath)
                }
                
                indexPathToRowColumn[indexPath] = (
                    row: section...(section + slotHeight - 1),
                    column: column...(column + slotWidth - 1)
                )
                
                //
                column += slotWidth
            }
            
            //
            results.append(.newRow())
            
            //
            indexPathSection = -1
            indexPathItem += 1
        }
        
        //
        return GridConfiguration(
            slots: slots,
            parseSlotStep: results,
            gridNumberOfRows: slotsFilleds.matrix.count,
            gridNumberOfColumns: slotsFilleds.matrix[0].count,
            indexPathToRowColumn: indexPathToRowColumn,
            cellPerRow: cellPerRow,
            cellPerColumn: cellPerColumn
        )
    }
    
    enum ParseSlotStep {
        case cell(row: Int, collumn: Int)
        case newRow()
    }
    
    func getCellOf(column: Int) -> Set<IndexPath> {
        return Set(cellPerColumn[column] ?? [])
    }
    
    func getCellOf(row: Int) -> Set<IndexPath> {
        return Set(cellPerRow[row] ?? [])
    }

    /**
     Return the size of a cell
     */
    class func cellSlotSize(slots: [[Slot]], section: Int, row: Int) -> (width: Int, height: Int) {
        let slotCell = slots[section][row].cell
        
        return (slotCell.slotWidth, slotCell.slotHeight)
    }
    
    func cellSlotSize(section: Int, row: Int) -> (width: Int, height: Int) {
        let slotCell = slots[section][row].cell
        
        return (slotCell.slotWidth, slotCell.slotHeight)
    }
}

fileprivate class MatrixBool {
    var matrix: [[Bool]]
    
    init(initialWidth: Int, initialHeight: Int) {
        
        let values = [Bool](repeating: false, count: initialWidth)
        matrix = []
        
        for _ in 0..<initialHeight {
            matrix.append(values)
        }
    }
    
    func growWidth(_ growCount: Int) {
        let newValues = [Bool](repeating: false, count: growCount)
        
        for i in 0..<matrix.count {
            matrix[i].append(contentsOf: newValues)
        }
    }
    
    func growHeight(_ growCount: Int) {
        let newValues = [Bool](repeating: false, count: matrix[0].count)
        
        for _ in 0..<growCount {
            matrix.append(newValues)
        }
    }
}
