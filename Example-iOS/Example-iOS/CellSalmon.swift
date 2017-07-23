//
//  CellRed.swift
//  Example-iOS
//
//  Created by Bruno Macabeus Aquino on 30/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

class CellSalmon: UICollectionViewCell, SlotableCell {
    
    static let slotWidth = 2
    static let slotHeight = 1
    static let myNib = UINib(nibName: "CellSalmon", bundle: nil)
    var slotParams: [String : Any] = [:]
    
    func load() {
        
    }
}
