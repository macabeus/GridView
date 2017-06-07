//
//  GridController.swift
//  GridView
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit

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
    
    func gridViewGestureToStartMoveAt(_ gridView: GridViewController) -> UIGestureRecognizer
    
    func gridView(_ gridView: GridViewController, newGridConfiguration: GridConfiguration)
}

public class GridViewController: UICollectionViewController, GridLayoutDelegate {
    
    public var gridConfiguration = GridConfiguration.create(slots: Slots(slots: [[]]))
    public var delegate: GridViewDelegate?
    private var editingMode = false
    private var dictCellToIndexPath: [UICollectionViewCell: IndexPath] = [:]

    lazy var gestureEditingModeStart: UIGestureRecognizer = { [unowned self] in
        
        let gesture = self.delegate!.gridViewGestureToStartMoveAt(self)
        gesture.addTarget(self, action: #selector(startEditingMode))
        
        return gesture
    }()
    
    lazy var gestureEditingModeStop: UITapGestureRecognizer = { [unowned self] in
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(stopEditingMode))
        gesture.isEnabled = false
        gesture.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
        
        return gesture
    }()
    
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
        
        // Add gesture to user can to move cells
        self.collectionView!.addGestureRecognizer(gestureEditingModeStart)
        self.collectionView!.addGestureRecognizer(gestureEditingModeStop)
        
        // Set background color clear, for default
        self.view.backgroundColor = UIColor.clear
    }
    
    ////
    // Create and show the cells at grid
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gridConfiguration.slots.numberOfSections()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridConfiguration.slots.numberOfItemsAt(section: section)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let slot = gridConfiguration.slots.slotAt(section: indexPath.section, item: indexPath.item)
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: getClassName(of: slot.cell)!, for: indexPath) as! SlotableCell
        
        // start cell
        cell.params = slot.params
        cell.load(params: slot.params)
        delegate!.setup(cell: cell, params: slot.params)
        
        //
        dictCellToIndexPath[cell as! UICollectionViewCell] = indexPath
        
        // add gesture to cell
        if let cell = cell as? UICollectionViewCell,
            let cellIndexPath = dictCellToIndexPath[cell],
            delegate!.gridView(self, shouldMoveCellAt: cellIndexPath) {
        }
        
        (cell as! UICollectionViewCell).contentView.isUserInteractionEnabled = false
        
        // for some reason, in some cases, the collectionview reuse the previus cell frame, and, we don't want this behavior; we want use the frame setted by GridLayout
        (cell as! UICollectionViewCell).frame = gridLayout.cache.first(where: { $0.indexPath == indexPath })!.frame
        
        //
        return cell as! UICollectionViewCell
    }
    
    ////
    // Focus
    public override func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        
        if editingMode {
            return false
        } else {
            return true
        }
    }
    
    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        context.previouslyFocusedView?.layer.shadowOpacity = 0.0
        context.nextFocusedView?.layer.shadowOpacity = 1.0
    }
    
    ////
    // Move cells
    private func indexPathToSlotableCell(_ indexPath: IndexPath) -> SlotableCell {
        for i in dictCellToIndexPath.enumerated() {
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
    
    private func move(cell cellTargetIndexPath: IndexPath, to direction: MoveDirection, completion: @escaping () -> ()) {
        
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
        
        if rowsAffectDest.count == 0 {
            // if haven't any cell in dest, then, the move is invalid
            let cell = self.indexPathToSlotableCell(cellTargetIndexPath) as! UICollectionViewCell
            
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    
                    cell.frame.origin = CGPoint(
                        x: cell.frame.origin.x + 150,
                        y: cell.frame.origin.y
                    )
                    
                },
                completion: { _ -> Void in
                    
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            
                            cell.frame.origin = CGPoint(
                                x: cell.frame.origin.x - 150,
                                y: cell.frame.origin.y
                            )
                            
                        }
                    )
                    
                    completion()
                }
            )
            
            return
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
        
        let cellToSwap: [(origin: IndexPath, dest: IndexPath)] =
            cellsAffectOrigin.map { indexPath in
                let mySideCells = sideCells(indexPath)
                
                let x = mySideCells.map { current -> (indexPath: IndexPath, columnSize: Int) in
                    let column = self.gridConfiguration.indexPathToRowColumn[current]!.column
                    
                    return (indexPath: current, columnSize: column.upperBound - column.lowerBound)
                }
                let largest = x.max(by: { $0.columnSize < $1.columnSize })!
                
                return (origin: indexPath, dest: largest.indexPath)
            }
        
        UIView.animate(
            withDuration: 0.5,
            animations: {
                
                var frameOriginToDest: [(cell: UICollectionViewCell, dest: CGPoint)] = []
                
                for i in cellToSwap {
                    let cellOrigin = self.indexPathToSlotableCell(i.origin) as! UICollectionViewCell
                    let cellDest = self.indexPathToSlotableCell(i.dest) as! UICollectionViewCell
                    
                    frameOriginToDest.append(
                        (
                            cell: cellOrigin,
                            dest: CGPoint(
                                x: cellOrigin.frame.origin.x + cellDest.frame.size.width + self.gridLayout.cellPadding * 2,
                                y: cellOrigin.frame.origin.y
                            )
                        )
                    )
                    
                    frameOriginToDest.append(
                        (
                            cell: cellDest,
                            dest: CGPoint(
                                x: cellOrigin.frame.origin.x,
                                y: cellDest.frame.origin.y
                            )
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
                        
                        let newGridConfiguration = GridConfiguration.create(slots: Slots(slots: newSlots))
                        
                        var cellsArray = (cellsPerRow.flatMap { $0 }).makeIterator()
                        
                        var indexPathSection = -1
                        var indexPathItem = 0
                        
                        for mySlot in self.gridConfiguration.parseSlotStep {
                            
                            indexPathSection += 1
                            
                            switch mySlot {
                            case .cell(_, _):
                                
                                let myCell = cellsArray.next()!
                                
                                self.dictCellToIndexPath[myCell] = IndexPath(
                                    item: indexPathSection,
                                    section: indexPathItem
                                )
                                
                            case .newRow():
                                
                                indexPathSection = -1
                                indexPathItem += 1
                            }
                            
                        }
                        
                        self.gridConfiguration = newGridConfiguration
                        self.delegate!.gridView(self, newGridConfiguration: newGridConfiguration)
                        completion()
                    }
                )
                
            }
        )
    }
    
    private func setEditingMode(enabled: Bool) {
        
        if enabled {
            editingMode = true
            gestureEditingModeStart.isEnabled = false
            gestureEditingModeStop.isEnabled = true
        } else {
            editingMode = false
            gestureEditingModeStart.isEnabled = true
            gestureEditingModeStop.isEnabled = false
        }
    }
    
    func startEditingMode(_ gesture: UIGestureRecognizer) {
        
        guard (gesture as? UILongPressGestureRecognizer != nil && gesture.state == .began) ||
            (gesture.state == .ended) else {
                
                return
        }
        
        collectionView!.visibleCells.forEach {
            $0.startWiggle()
        }
        
        let currentFocusedCell = UIScreen.main.focusedItem as! UICollectionViewCell
        let gestureMoveCell = UIPanGestureRecognizer()
        gestureMoveCell.addTarget(self, action: #selector(doRearrange))
        currentFocusedCell.addGestureRecognizer(gestureMoveCell)
        
        setEditingMode(enabled: true)
    }
    
    func stopEditingMode(_ gesture: UIGestureRecognizer) {
        collectionView!.visibleCells.forEach {
            $0.stopWiggle()
        }
        
        let currentFocusedCell = UIScreen.main.focusedItem as! UICollectionViewCell
        let gestureMoveCell = currentFocusedCell.gestureRecognizers!.first(where: { ($0 as? UIPanGestureRecognizer) != nil })! // todo: this any to get the gesture created in startEditingMode(_:) is unsafe!
        currentFocusedCell.removeGestureRecognizer(gestureMoveCell)
        
        setEditingMode(enabled: false)
    }
    
    func doRearrange(_ gesture: UIPanGestureRecognizer) {
        
        guard gesture.state == .ended, editingMode == true else {
            return
        }
        
        let indexPath = dictCellToIndexPath[gesture.view! as! UICollectionViewCell]!
        gesture.isEnabled = false
        
        move(cell: indexPath, to: gesture.direction) {
            gesture.isEnabled = true
        }
    }
    
    ////
    // public functions to user
    
    /**
     If you changed the *gridConfiguration* and want reload the grid, use this method.
     **NEVER** use *reloadData()*
     */
    public func reloadGrid() {
        (collectionView!.collectionViewLayout as! GridLayout).clearCache()
        collectionView!.reloadData()
    }
    
    /**
     Return the params of one cell
     */
    public func getParams(of cell: UICollectionViewCell) -> [String: Any] {
        let indexPath = dictCellToIndexPath[cell]!
        let cellTarget = indexPathToSlotableCell(indexPath)
        
        return cellTarget.params
    }
    
}
