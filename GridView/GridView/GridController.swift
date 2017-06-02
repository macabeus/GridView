//
//  GridController.swift
//  GridView
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit

infix operator ~
func ~<T> (left: CountableClosedRange<T>, right: CountableClosedRange<T>) -> Bool {
    for i in right {
        if left.contains(i) {
            return true
        }
    }
    
    return false
}

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
     */
    var params: [String: Any] { get set }
    
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
    func setup(cell: SlotableCell, params: [String: Any])
    
    func gridView(_ gridView: GridViewController, shouldMoveCellAt indexPath: IndexPath) -> Bool
    
    func gridView(_ gridView: GridViewController, gestureToStartMoveAt indexPath: IndexPath) -> UIGestureRecognizer
}

public class GridViewController: UICollectionViewController, GridLayoutDelegate {
    
    public var gridConfiguration = GridConfiguration(slots: [[]])
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
        return gridConfiguration.slots.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridConfiguration.slots[section].count
    }
    
    var originalIndexPathToCell: [IndexPath: UICollectionViewCell] = [:]
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let slot = gridConfiguration.slots[indexPath.section][indexPath.row]
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: getClassName(of: slot.cell)!, for: indexPath) as! SlotableCell
        
        //
        cell.params = slot.params
        cell.load(params: slot.params)
        delegate!.setup(cell: cell, params: slot.params)
        
        //
        gridConfiguration.cellToIndexPath[cell as! UICollectionViewCell] = indexPath
        
        //
        originalIndexPathToCell[indexPath] = (cell as! UICollectionViewCell)
        
        //
        return cell as! UICollectionViewCell
    }
    
    //
    func getClassName(of any: Any) -> String? {
        return "\(any)".components(separatedBy: ".").last
    }
    
    //
    public override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        context.previouslyFocusedView?.layer.shadowOpacity = 0.0
        context.nextFocusedView?.layer.shadowOpacity = 1.0
        
        if let cell = context.nextFocusedView as? UICollectionViewCell,
            let cellIndexPath = gridConfiguration.cellToIndexPath[cell],
            delegate!.gridView(self, shouldMoveCellAt: cellIndexPath) {
            
            let gesture = delegate!.gridView(self, gestureToStartMoveAt: cellIndexPath)
            gesture.addTarget(self, action: #selector(self.rearrange))
            cell.addGestureRecognizer(gesture)
        }
    }
    
    private func indexPathToSlotableCell(_ indexPath: IndexPath) -> SlotableCell {
        for i in gridConfiguration.cellToIndexPath.enumerated() {
            if i.element.value == indexPath {
                return i.element.key as! SlotableCell
            }
        }
        
        fatalError()
    }
    
    var gridLayout: GridLayout {
        return (collectionView!.collectionViewLayout as! GridLayout)
    }
    
    private func sideCells(_ cellTargetIndexPath: IndexPath) -> Set<IndexPath> {
        
        let cellTargetRowColumn = gridConfiguration.indexPathToRowColumn[cellTargetIndexPath]!
        let cellTarget = indexPathToSlotableCell(cellTargetIndexPath)
        let slotWidth = type(of: cellTarget).slotWidth
        
        ////
        // check the cells will be affected on destination
        
        // possíveis células afetadas no destino devido a altura
        var cellsAtRigthByRigth: Set<IndexPath> = Set()
        for i in cellTargetRowColumn.row {
            
            cellsAtRigthByRigth = cellsAtRigthByRigth.union(
                gridConfiguration.getCellOf(row: i)
            )
        }
        cellsAtRigthByRigth.remove(cellTargetIndexPath)
        
        // possíveis células afetadas no destino devido a largura
        var cellsAtRigthByTop: Set<IndexPath> = Set()
        for i in cellTargetRowColumn.column {
            
            let index = i + slotWidth
            
            cellsAtRigthByTop = cellsAtRigthByTop.union(
                gridConfiguration.getCellOf(column: index)
            )
        }
        
        //
        let cellAffectedAtDestination = cellsAtRigthByRigth.intersection(cellsAtRigthByTop)
        
        //
        return cellAffectedAtDestination
    }
    
    private func move(cell cellTargetIndexPath: IndexPath) {
        
        let cellTargetRowColumn = gridConfiguration.indexPathToRowColumn[cellTargetIndexPath]!
        let cellTarget = indexPathToSlotableCell(cellTargetIndexPath)
        let slotWidth = type(of: cellTarget).slotWidth
        
        ////
        // check the cells will be affected on destination
        
        // possíveis células afetadas no destino devido a altura
        var cellsAtSamesRows: Set<IndexPath> = Set()
        for i in cellTargetRowColumn.row {
            
            cellsAtSamesRows = cellsAtSamesRows.union(
                gridConfiguration.getCellOf(row: i)
            )
            
        }
        cellsAtSamesRows.remove(cellTargetIndexPath)
        
        // possíveis células afetadas no destino devido a largura
        var cellsAtRigthByTop: Set<IndexPath> = Set()
        for i in cellTargetRowColumn.column {
            
            let index = i + slotWidth
            
            cellsAtRigthByTop = cellsAtRigthByTop.union(
                gridConfiguration.getCellOf(column: index)
                //gridLayout.getCellOf(column: index)
            )
        }
        
        // filtrar para saber quais células realmente serão afetadas no destino
        let cellAffectedAtDestination = cellsAtSamesRows.intersection(cellsAtRigthByTop)
        
        ////
        // check the cells will be affected on origin
        
        // get the max row and min row of destination affected cell
        let rowsAffectDest = cellAffectedAtDestination.map {
            gridConfiguration.indexPathToRowColumn[$0]!.row
        }
        
        let rangeRowsAffectDest = rowsAffectDest.reduce(rowsAffectDest[0]) { oldValue, currentValue in
            let lowerBound = min(oldValue.lowerBound, currentValue.lowerBound)
            let upperBound = max(oldValue.upperBound, currentValue.upperBound)
            
            return lowerBound...upperBound
        }
        
        // get the cells will be affected in origin
        let cellsAffectOrigin = gridConfiguration.getCellOf(column: cellTargetRowColumn.column.upperBound).filter { c in
            self.gridConfiguration.indexPathToRowColumn[c]!.row ~ rangeRowsAffectDest
        }
        
        ////
        // animate
        
        var cellToSwap: [(origin: IndexPath, dest: IndexPath, destColumnSize: Int)] = []
        
        for i in cellsAffectOrigin {
            let mySideCells = sideCells(i)
            
            let x = mySideCells.map { current -> ((IndexPath), Int) in
                let column = self.gridConfiguration.indexPathToRowColumn[current]!.column //self.gridLayout.indexPathToRowColumn[current]!.column
                
                return (current, column.upperBound - column.lowerBound)
            }
            let largest = x.max(by: { $0.1 < $1.1 })!
            
            cellToSwap.append((origin: i, dest: largest.0, destColumnSize: largest.1))
        }
        
        var frameOriginToDest: [(cell: UICollectionViewCell, dest: CGPoint)] = []
        
        UIView.animate(
            withDuration: 0.5,
            animations: {
                
                for i in cellToSwap {
                    //
                    let cell = self.indexPathToSlotableCell(i.origin) as! UICollectionViewCell
                    let cellDest =
                        (self.indexPathToSlotableCell(i.dest) as! UICollectionViewCell).frame.origin.x +
                        (CGFloat(i.destColumnSize) * self.gridLayout.columnWidth)
                    
                    frameOriginToDest.append(
                        (
                            cell: cell,
                            dest: CGPoint(x: cellDest, y: cell.frame.origin.y)
                        )
                    )
                    
                    //
                    let cellDestAffect = self.indexPathToSlotableCell(i.dest) as! UICollectionViewCell
                    
                    frameOriginToDest.append(
                        (
                            cell: cellDestAffect,
                            dest: CGPoint(x: cell.frame.origin.x, y: cellDestAffect.frame.origin.y)
                        )
                    )
                }
                
                frameOriginToDest.forEach {
                    $0.cell.frame.origin = $0.dest
                }
            
            }, completion: { _ -> Void in
                
                let cellToSwap = cellToSwap
                let rangeRowsAffectDest = rangeRowsAffectDest
                
                var cellsOverlapping: [UICollectionViewCell] = []
                
                for i in rangeRowsAffectDest {
                    let cellsAndOriginX = self.gridConfiguration.getCellOf(row: i).map { ($0, (self.indexPathToSlotableCell($0) as! UICollectionViewCell).frame.origin.x) }
                    var originX = cellsAndOriginX.map { Float($0.1) }
                    Set(originX).forEach { originX.remove(at: originX.index(of: $0)!) }
                    
                    let transform = cellsAndOriginX
                        .filter({ originX.contains(Float($0.1)) })
                        .filter({ current -> Bool in !cellToSwap.contains { $0.dest == current.0  || $0.origin == current.0 } })
                        .map({ $0.0 })
                        .map({ self.indexPathToSlotableCell($0) as! UICollectionViewCell })
                    
                    cellsOverlapping.append(contentsOf: transform)
                }
                
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        
                        for i in cellsOverlapping {
                            i.frame.origin = CGPoint(
                                x: i.frame.origin.x - self.gridLayout.columnWidth,
                                y: i.frame.origin.y
                            )
                        }
                        
                    }, completion: { _ -> Void in
                        
                        let collectionView = self.collectionView!
                        let cellsSorted = collectionView.visibleCells
                            .sorted(by: { $0.0.frame.origin.x < $0.1.frame.origin.x })
                            .sorted(by: { $0.0.frame.origin.y < $0.1.frame.origin.y })
                        
                        let cellsPerRow = cellsSorted
                            .reduce([CGFloat: [UICollectionViewCell]]()) {
                                result, value -> [CGFloat: [UICollectionViewCell]] in
                            
                                let originY = value.frame.origin.y
                                var temp = result
                                if let _ = temp[originY] {
                                    temp[originY]!.append(value)
                                } else {
                                    temp[originY] = [value]
                                }
                            
                                return temp
                            }.sorted {
                                $0.0.key < $0.1.key
                            }.map {
                                $0.value
                            }
                        
                        var newSlots = [[Slot]]()
                        for i in cellsPerRow {
                            
                            let slots = i.map {
                                Slot(cell: type(of: $0) as! SlotableCell.Type, params: ($0 as! SlotableCell).params)
                            }
                            
                            newSlots.append(slots)
                        }
                        
                        let newGridConfiguration = GridConfiguration(slots: newSlots)
                        
                        var cellsArray = (cellsPerRow.flatMap { $0 }).makeIterator()
                        
                        var indexPathSection = -1
                        var indexPathItem = 0
                        
                        for mySlot in self.gridConfiguration.parseSlots() {
                            
                            indexPathSection += 1
                            
                            switch mySlot {
                            case .cell(_, _):
                                
                                let myCell = cellsArray.next()!
                                
                                newGridConfiguration.cellToIndexPath[myCell] = IndexPath(
                                    item: indexPathSection,
                                    section: indexPathItem
                                )
                                
                            case .newRow():
                                
                                indexPathSection = -1
                                indexPathItem += 1
                            }
                            
                        }
                        
                        self.gridConfiguration = newGridConfiguration
                        
                        (cellTarget as! UICollectionViewCell).gestureRecognizers!.forEach { $0.isEnabled = true }
                    }
                )
                
            }
        )
    }
    
    public func rearrange(_ cell: UITapGestureRecognizer) {
        
        guard cell.state == .ended else {
            return
        }
        
        let indexPath = gridConfiguration.cellToIndexPath[cell.view! as! UICollectionViewCell]!
        
        print(getParams(of: cell.view! as! UICollectionViewCell))
        cell.view!.gestureRecognizers!.forEach { $0.isEnabled = false }
        move(cell: indexPath)
    }
    
    public func getParams(of cell: UICollectionViewCell) -> [String: Any] {
        let indexPath = gridConfiguration.cellToIndexPath[cell]!
        let cellTarget = indexPathToSlotableCell(indexPath)
        
        return cellTarget.params
    }
    
}
