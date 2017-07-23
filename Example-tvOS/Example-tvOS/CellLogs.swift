//
//  CellInsignia.swift
//  Example-tvOS
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

class CellLogs: UICollectionViewCell, SlotableCell {
 
    static let slotWidth = 2
    static let slotHeight = 1
    var slotParams: [String : Any] = [:]

    func load() {
        
    }
}

extension CellLogs: CellRealTimeProtocol {
    func connect() {
        // connecting in my amazing server...
    }
}
