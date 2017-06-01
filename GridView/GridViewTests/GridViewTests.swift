//
//  GridViewTests.swift
//  GridViewTests
//
//  Created by Bruno Macabeus Aquino on 31/05/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Quick
import Nimble
import GridView

class CellBlue: SlotableCell {
    
    static let slotWidth = 1
    static let slotHeight = 1
    var params: [String : Any] = [:]
    
    func load(params: [String: Any]) {
        
    }
}

extension GridConfiguration.ParseSlotStep: Equatable {
    
    static func ==(lhs: GridConfiguration.ParseSlotStep, rhs: GridConfiguration.ParseSlotStep) -> Bool {
        if case .cell(row: let rowLhs, collumn: let columnLhs) = lhs,
            case .cell(row: let rowRhs, collumn: let columnRhs) = rhs {
            
            return (rowLhs == rowRhs) && (columnLhs == columnRhs)
        } else if case .newRow() = lhs, case .newRow() = rhs {
            
            return true
        } else {
            
            return false
        }
    }
}

class GridConfigurationTests: QuickSpec {
    override func spec() {
        
        describe("a gridConfiguration") {
            describe("empty grid") {
                let emptyGridConfiguration = GridConfiguration(slots: [[]])
                
                it("check total of rows") {
                    expect(emptyGridConfiguration.gridNumberOfRows()).to(equal(1))
                }

                it("check total of columns") {
                    expect(emptyGridConfiguration.gridNumberOfColumns()).to(equal(0))
                }
            }
            
            describe("grid with one row and tree columns") {
                let filledGridConfiguration = GridConfiguration(slots:
                    [
                        [Slot(cell: CellBlue.self, params: [:]), Slot(cell: CellBlue.self, params: [:]), Slot(cell: CellBlue.self, params: [:])]
                    ]
                )
                
                it("check total of rows") {
                    expect(filledGridConfiguration.gridNumberOfRows()).to(equal(1))
                }
                
                it("check total of columns") {
                    expect(filledGridConfiguration.gridNumberOfColumns()).to(equal(3))
                }

                it("check parse slots") {
                    let testParseSlots = filledGridConfiguration.parseSlots()
                    
                    let mockParseSlots: [GridConfiguration.ParseSlotStep] = [
                        .cell(row: 0, collumn: 0), .cell(row: 0, collumn: 1), .cell(row: 0, collumn: 2), .newRow()
                    ]
                    
                    expect(testParseSlots.count).to(equal(mockParseSlots.count))
                    
                    for i in zip(testParseSlots, mockParseSlots) {
                        
                        expect(i.0).to(equal(i.1))
                    }
                }
            }
        }
    }
}
