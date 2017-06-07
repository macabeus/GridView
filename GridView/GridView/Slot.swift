//
//  Slot.swift
//  GridView
//
//  Created by Bruno Macabeus Aquino on 07/06/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import Foundation

/**
 Struct to encapsulate the cell with yours parameters, to show in grid.
 The parameters are passed to *setup(cell:params)* and *load(params)* methods
 */
public struct Slot {
    public let cell: SlotableCell.Type
    public let params: [String: Any]
    
    public init(cell: SlotableCell.Type, params: [String: Any]) {
        self.cell = cell
        self.params = params
    }
}

public class Slots {
    
    private let slots: [[Slot]]
    
    public init(slots: [[Slot]]) {
        self.slots = slots
    }
    
    func numberOfSections() -> Int {
        return slots.count
    }
    
    func numberOfItemsAt(section: Int) -> Int {
        return slots[section].count
    }
    
    func slotAt(section: Int, item: Int) -> Slot {
        return slots[section][item]
    }
    
    /**
     Return the size of a cell
     */
    func slotSizeAt(section: Int, item: Int) -> (width: Int, height: Int) {
        let slot = slots[section][item].cell
        
        return (slot.slotWidth, slot.slotHeight)
    }
}
