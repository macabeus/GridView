//
//  CellSky.swift
//  Example-iOS
//
//  Created by Bruno Macabeus Aquino on 30/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

class CellSky: UICollectionViewCell, SlotableCell {
    
    static let slotWidth = 1
    static let slotHeight = 1
    static let myNib = UINib(nibName: "CellSky", bundle: nil)
    var slotParams: [String : Any] = [:]
    
    func load() {
        
    }
}
