//
//  MainTvController.swift
//  Example-tvOS
//
//  Created by Bruno Macabeus Aquino on 27/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

class MainTvController: UIViewController {

    @IBOutlet weak var container: UIView!
    var containerGrid: GridViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
        
        // set the cells to show in grid 📌
        let slots: [[Slot]] = [
            [Slot(cell: CellBlue.self, params: ["p": 0]), Slot(cell: CellGreen.self, params: ["p": 1]), Slot(cell: CellBlue.self, params: ["p": 2])],
            [Slot(cell: CellGreen.self, params: ["p": 3]), Slot(cell: CellBlue.self, params: ["p": 4])],
            [Slot(cell: CellYellow.self, params: ["p": 5])],
            [Slot(cell: CellBlue.self, params: ["p": 6]), Slot(cell: CellBlue.self, params: ["p": 7]), Slot(cell: CellBlue.self, params: ["p": 8])]
        ]
        
        /*let slots: [[Slot]] = [
            [Slot(cell: CellMap.self, params: [:]), Slot(cell: CellChart.self, params: [:])],
            [Slot(cell: CellLogs.self, params: [:])],
            [Slot(cell: CellCharacter.self, params: ["race": "troll"]), Slot(cell: CellCharacter.self, params: ["race": "elves"]), Slot(cell: CellCharacter.self, params: ["race": "undead"]), Slot(cell: CellCharacter.self, params: ["race": "merfolk"])]
        ]*/
        
        containerGrid!.gridConfiguration = GridConfiguration(slots: slots)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueGrid" {
            self.containerGrid = (segue.destination as! GridViewController)
            self.containerGrid!.delegate = self
        }
    }
}

extension MainTvController: GridViewDelegate {
    func getCellToRegister() -> [SlotableCell.Type] {
        // we need register cell's class, then, send it's where 🖋
        return [CellCharacter.self, CellLogs.self, CellMap.self, CellChart.self,
                CellBlue.self, CellGreen.self, CellYellow.self]
        
        // if do you want list all classes that subscreber the SlotableCell protocol, you can read use this gist: https://gist.github.com/brunomacabeusbr/eea343bb9119b96eed3393e41dcda0c9 💜
    }
    
    func setup(cell: SlotableCell, params: [String: Any]) {
        // this delegate is called in "collectionView(_:cellForItemAt)" from GridViewController
        // it's useful when we need to setup many cells with same code 🍡
        
        // for example, connect to server, if a cell need
        if let cellRealTime = cell as? CellRealTimeProtocol {
            cellRealTime.connect()
        }
        
        // for example, sey layout
        (cell as! UICollectionViewCell).layer.shadowColor = UIColor.white.cgColor
        (cell as! UICollectionViewCell).layer.cornerRadius = 10
    }
    
    func gridView(_ gridView: GridViewController, shouldMoveCellAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func gridView(_ gridView: GridViewController, gestureToStartMoveAt indexPath: IndexPath) -> UIGestureRecognizer {
        
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 2
        return gesture
    }
}
