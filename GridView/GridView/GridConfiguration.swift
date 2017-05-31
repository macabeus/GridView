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
    private var cellPerRow: [Int: [IndexPath]] = [:]
    private var cellPerColumn: [Int: [IndexPath]] = [:]
    var cellToIndexPath: [UICollectionViewCell: IndexPath] = [:]
    var indexPathToRowColumn: [IndexPath: (row: CountableClosedRange<Int>, column: CountableClosedRange<Int>)] = [:]
    
    public init(slots: [[Slot]]) {
        
        self.slots = slots
        _ = parseSlots()
    }
    
    enum ParseSlotStep {
        case cell(row: Int, collumn: Int)
        case newRow()
    }
    
    func parseSlots() -> [ParseSlotStep] {
        
        var results: [ParseSlotStep] = []
        cellPerRow = [:]
        cellPerColumn = [:]
        indexPathToRowColumn = [:]
        
        //
        var slotsFilleds: [[Bool]] = []
        for _ in 0..<gridNumberOfRows() {
            slotsFilleds.append([Bool](repeating: false, count: gridNumberOfColumns()))
        }
        
        // fill the collection view
        var indexPathSection = -1
        var indexPathItem = 0
        
        var column: Int
        let totalColumns = maxRow()
        var columnsFill: Int
        
        for section in 0..<slots.count {
            column = 0
            columnsFill = 0
            
            if slots[section].count > 0 {
                // get the first column with free space
                while slotsFilleds[section][columnsFill] {
                    columnsFill += 1
                }
                column = columnsFill
            } else {
                // if the row don't have a cell
                columnsFill = totalColumns
            }
            
            //
            for item in 0..<slots[section].count {
                indexPathSection += 1
                //let indexPath = IndexPath(item: item, section: section)
                
                // set size of cell
                let slotSize = cellSlotSize(section: section, row: item)
                let slotWidth = slotSize.width
                let slotHeight = slotSize.height
                
                //
                columnsFill += slotWidth
                
                // checar se tem espaço nessa coluna; se não tiver, ir para o próximo espaço vago
                // todo: talvez se isso ficar no começo desse for fique mais legível
                while slotsFilleds[section][column] {
                    column += 1
                    columnsFill += 1
                    if column == gridNumberOfColumns() {
                        print("[WARNING GridLayout] Célula de \(section):\(item) ultrapassou os limites!")
                    }
                }
                
                // atualizar yOffset e contentHeight
                for i in 0..<slotHeight {
                    for j in 0..<slotWidth {
                        slotsFilleds[section + i][column + j] = true
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
        
        return results
    }
    
    func getCellOf(column: Int) -> Set<IndexPath> {
        return Set(cellPerColumn[column] ?? [])
    }
    
    func getCellOf(row: Int) -> Set<IndexPath> {
        return Set(cellPerRow[row] ?? [])
    }
    
    /**
     Return length of row with max length
     */
    func maxRow() -> Int {
        return slots.map({ $0.reduce(0) { $0 + $1.cell.slotWidth } }).max()!
    }
    
    /**
     Return the size of a cell
     */
    func cellSlotSize(section: Int, row: Int) -> (width: Int, height: Int) {
        let slotCell = slots[section][row].cell
        
        return (slotCell.slotWidth, slotCell.slotHeight)
    }
    
    /**
     Return total number of rows
     */
    // as funções gridNumberOfRows e gridNumberOfColumns seguem um algoritimo parecido,
    // para computar a quantidade de linhas e colunas, respectivamente, que a grid precisará
    // o algoritimo é o seguinte:
    // 1 - armazenará na variável yOffset o buffer de quantas linhas são necessárias para desenhar a célula da linha atual
    // 2 - em "gridConfiguration.slots.forEach" computaremos linha a linha da grid
    // 3 - em "while yOffset[index] != 0 {" finalizando a computação da linha, então, como já usamos uma linha para desenhar a célula, apagaremos em 1 cada item de yOffset
    func gridNumberOfRows() -> Int {
        var yOffset: [Int] = [Int](repeating: 0, count: 10)
        
        var maxIndex = 0
        slots.forEach {
            var index = 0
            $0.forEach {
                while yOffset[index] != 0 {
                    index += 1
                }
                
                yOffset[index] = $0.cell.slotHeight
                if index > maxIndex {
                    maxIndex = index
                }
            }
            index = 0
            
            while yOffset[index] != 0 {
                yOffset[index] -= 1
                index += 1
            }
        }
        
        // a quantidade de linhas necessárias para se desenhar a grid é o quanto sobrou para desenhar a célula (ou seja, yOffset.max) + quantas linhas foram necessárias para desenhar as demais células (gridConfiguration.slots.count)
        return yOffset.max()! + slots.count
    }
    
    /**
     Return total number of columns
     */
    func gridNumberOfColumns() -> Int {
        var yOffset: [Int] = [Int](repeating: 0, count: 10)
        
        var maxIndex = 0
        slots.forEach {
            var index = 0
            $0.forEach {
                while yOffset[index] != 0 {
                    index += 1
                }
                
                for _ in 0..<$0.cell.slotWidth {
                    yOffset[index] = $0.cell.slotHeight
                    index += 1
                }
                if index > maxIndex {
                    maxIndex = index
                }
            }
            index = 0
            
            while yOffset[index] != 0 {
                yOffset[index] -= 1
                index += 1
            }
        }
        
        // a quantidade de colunas necessárias para desenhar a grid é o maior índice necessário que foi usado em yOffset (armazenado em maxIndex)
        return maxIndex
    }

}
