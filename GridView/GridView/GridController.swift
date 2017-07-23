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
    
    /**
     Dictionary with the parameters defined in the slot of this cell
     */
    var slotParams: [String: Any] { get set }
    
    /**
     This method if called when a cell is created in grid
    */
    func load()
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
    func setup(cell: SlotableCell)
}

public class GridViewController: UICollectionViewController, GridLayoutDelegate {
    
    public var gridConfiguration = GridConfiguration.create(slots: Slots(slots: [[]]))
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
    
    var gridLayout: GridLayout {
        return (collectionView!.collectionViewLayout as! GridLayout)
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
        return gridConfiguration.slots.numberOfSections()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridConfiguration.slots.numberOfItemsAt(section: section)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let slot = gridConfiguration.slots.slotAt(section: indexPath.section, item: indexPath.item)
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: getClassName(of: slot.cell)!, for: indexPath) as! SlotableCell
        
        // start cell
        cell.slotParams = slot.params
        cell.load()
        delegate!.setup(cell: cell)
        
        // for some reason, in some cases, the collectionview reuse the previus cell frame, and, we don't want this behavior; we want use the frame setted by GridLayout
        (cell as! UICollectionViewCell).frame = gridLayout.cache.first(where: { $0.indexPath == indexPath })!.frame
        
        //
        return cell as! UICollectionViewCell
    }
    
    //
    func getClassName(of any: Any) -> String? {
        return "\(any)".components(separatedBy: ".").last
    }
}
