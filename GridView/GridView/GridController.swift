//
//  GridController.swift
//  GridView
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit

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

/**
 If do you want that a cell to be displayed in the grid, you need to subscriber the SlotableCell protocol.
 You also need create a xib with UI of this cell. The xib, and cell's indentifier in xib file, **need** have the same name of the class.
 */
public protocol SlotableCell {
    
    /**
     Size of cell in grid
    */
    static var slotWidth: Int { get }
    
    /**
     Size of cell in grid
     */
    static var slotHeight: Int { get }
    
    /**
     This method if called when a cell is created in grid
    */
    func load(params: [String: Any])
}

/**
 You need subscriber this protocol to manager a GridViewController
 */
public protocol GridViewDelegate {
    /**
     Register the cells that this grid can draw. All cells need to subscriber a SlotableCell protocol
     */
    func getCellToRegister() -> [SlotableCell.Type]
    
    /**
     This delegate is called in *collectionView(_:cellForItemAt)* from *GridViewController*.
     It's useful when we need to setup many cells with same code
    */
    func setup(cell: UICollectionViewCell, params: [String: Any])
}

public class GridViewController: UICollectionViewController {
    
    public var gridConfiguration: [[Slot]]?
    public var delegate: GridViewDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.collectionViewLayout = GridLayout()
        (collectionView!.collectionViewLayout as! GridLayout).delegate = self
        
        // Register cells
        let cells = delegate!.getCellToRegister()
        
        cells.forEach {
            let className = getClassName(of: $0)!
            let nib = UINib(nibName: className, bundle: Bundle(for: $0 as! AnyClass))
            
            collectionView!.register(nib, forCellWithReuseIdentifier: className)
        }
        
        // Set grid blank, for default
        gridConfiguration = [[]]
        
        // Set background color clear, for default
        self.view.backgroundColor = UIColor.clear
    }
    
    /**
     If you changed the *gridConfiguration* and want reload the grid, use this method.
     **NEVER** use *reloadData()*
    */
    public func reloadGrid() {
        (collectionView!.collectionViewLayout as! GridLayout).clearCache()
        collectionView!.reloadData()
    }
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gridConfiguration!.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridConfiguration![section].count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let slot = gridConfiguration![indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: getClassName(of: slot.cell)!, for: indexPath)
        
        (cell as! SlotableCell).load(params: slot.params)
        delegate!.setup(cell: cell, params: slot.params)
        
        return cell
    }
    
    //
    func getClassName(of any: Any) -> String? {
        return "\(any)".components(separatedBy: ".").last
    }
}

extension GridViewController: GridLayoutDelegate {
    func maxRow() -> Int {
        return gridConfiguration!.map({ $0.reduce(0) { $0 + $1.cell.slotWidth } }).max()!
    }
    
    func cellSlotSize(section: Int, row: Int) -> (width: Int, height: Int) {
        let slotCell = gridConfiguration![section][row].cell
        
        return (slotCell.slotWidth, slotCell.slotHeight)
    }
    
    // as funções gridNumberOfRows e gridNumberOfColumns seguem um algoritimo parecido,
    // para computar a quantidade de linhas e colunas, respectivamente, que a grid precisará
    // o algoritimo é o seguinte:
    // 1 - armazenará na variável yOffset o buffer de quantas linhas são necessárias para desenhar a célula da linha atual
    // 2 - em "gridConfiguration.slots.forEach" computaremos linha a linha da grid
    // 3 - em "while yOffset[index] != 0 {" finalizando a computação da linha, então, como já usamos uma linha para desenhar a célula, apagaremos em 1 cada item de yOffset
    func gridNumberOfRows() -> Int {
        var yOffset: [Int] = [Int](repeating: 0, count: 10)
        
        var maxIndex = 0
        gridConfiguration!.forEach {
            var index = 0
            $0.forEach {
                while yOffset[index] != 0 {
                    index += 1
                }
                
                yOffset[index] = $0.cell.slotHeight
                if index > maxIndex {
                    maxIndex = index
                }
            }
            index = 0
            
            while yOffset[index] != 0 {
                yOffset[index] -= 1
                index += 1
            }
        }
        
        // a quantidade de linhas necessárias para se desenhar a grid é o quanto sobrou para desenhar a célula (ou seja, yOffset.max) + quantas linhas foram necessárias para desenhar as demais células (gridConfiguration.slots.count)
        return yOffset.max()! + gridConfiguration!.count
    }
    
    func gridNumberOfColumns() -> Int {
        var yOffset: [Int] = [Int](repeating: 0, count: 10)
        
        var maxIndex = 0
        gridConfiguration!.forEach {
            var index = 0
            $0.forEach {
                while yOffset[index] != 0 {
                    index += 1
                }
                
                for _ in 0..<$0.cell.slotWidth {
                    yOffset[index] = $0.cell.slotHeight
                    index += 1
                }
                if index > maxIndex {
                    maxIndex = index
                }
            }
            index = 0
            
            while yOffset[index] != 0 {
                yOffset[index] -= 1
                index += 1
            }
        }
        
        // a quantidade de colunas necessárias para desenhar a grid é o maior índice necessário que foi usado em yOffset (armazenado em maxIndex)
        return maxIndex
    }
}
