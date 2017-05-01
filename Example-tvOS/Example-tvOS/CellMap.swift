//
//  CellMap.swift
//  Example-tvOS
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

// if do you want that a cell to be displayed in the grid, you need to subscriber the SlotableCell protocol ⚠️
// The xib, and cell's indentifier in xib file, *need* have the same name of the class ⚠️
class CellMap: UICollectionViewCell, SlotableCell {
    
    @IBOutlet weak var image: UIImageView!
    static let slotWidth = 2 // size of cell in grid
    static let slotHeight = 2 // size of cell in grid
    
    func load(params: [String: Any]) {
        // this method if called when a cell is created in grid
        // you can see a example more complete in CellCharacter 🏃
    }
}
