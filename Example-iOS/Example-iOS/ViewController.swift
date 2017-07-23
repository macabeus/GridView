//
//  ViewController.swift
//  Example-iOS
//
//  Created by Bruno Macabeus Aquino on 27/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

// ⚠️ please, read code in Example-tvOS, because this is more complete ⚠️

class ViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    var containerGrid: GridViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerGrid!.gridConfiguration = GridConfiguration.create(slots: Slots(slots: [
            [Slot(cell: CellSalmon.self, params: [:])],
            [Slot(cell: CellSky.self, params: [:]), Slot(cell: CellSky.self, params: [:])]
        ]))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueGrid" {
            self.containerGrid = (segue.destination as! GridViewController)
            self.containerGrid!.delegate = self
        }
    }
}

extension ViewController: GridViewDelegate {
    func getCellToRegister() -> [SlotableCell.Type] {
        return [CellSalmon.self, CellSky.self]
    }
    
    func setup(cell: SlotableCell) {
        (cell as? UICollectionViewCell)?.layer.cornerRadius = 10
    }
}
