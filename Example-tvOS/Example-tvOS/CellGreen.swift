//
//  CellGreen.swift
//  Example-tvOS
//
//  Created by Bruno Macabeus Aquino on 24/05/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

class CellGreen: UICollectionViewCell, SlotableCell {
    
    @IBOutlet weak var label: UILabel!
    static let slotWidth = 1
    static let slotHeight = 2
    var params: [String : Any] = [:]
    
    func load(params: [String: Any]) {
        
        label.text = "\(Unmanaged.passUnretained(self).toOpaque())"
    }
}
