//
//  CellChart.swift
//  Example-tvOS
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

class CellChart: UICollectionViewCell, SlotableCell {
    
    @IBOutlet weak var chart: UIImageView!
    static let slotWidth = 2
    static let slotHeight = 1
    var slotParams: [String : Any] = [:]
    
    func load() {
        chart.contentMode = .scaleAspectFill
    }
}

extension CellChart: CellRealTimeProtocol {
    func connect() {
        // connecting in my amazing server...
    }
}
