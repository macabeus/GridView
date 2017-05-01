[![Version](https://img.shields.io/cocoapods/v/TvLightSegments.svg?style=flat)](http://cocoapods.org/pods/TvLightSegments)
[![License](https://img.shields.io/cocoapods/l/TvLightSegments.svg?style=flat)](http://cocoapods.org/pods/TvLightSegments)
[![Platform](https://img.shields.io/cocoapods/p/TvLightSegments.svg?style=flat)](http://cocoapods.org/pods/TvLightSegments)

# GridView
📜  Amazing grid view in your tvOS/iOS app

![](http://i.imgur.com/Zn3c7bD.png)

You can download this repository and see this example app.

# How to use

## Install
In `Podfile` add
```
pod 'GridView'
```

and use `pod install`.

## Setup

### Storyboard
![](http://i.imgur.com/nNbAekE.png)

1. Create a Container View
2. Change the View Controller for Collection View Controller
3. Set *GridViewController* as a custom class

### Create a cell

To display a cell in grid, the cell need be a `UICollectionViewCell` and subscriber the protocol `SlotableCell`.
And, you need create a xib file with Collection View Cell. The xib, and cell's indentifier in xib file, **need** have the same name of the class.

Minimal example:

```swift
import UIKit
import GridView

class CellLogs: UICollectionViewCell, SlotableCell {
 
    static let slotWidth = 1 // size of cell in grid 📏
    static let slotHeight = 1 // size of cell in grid 📐

    func load(params: [String: Any]) { 
        // this method if called when a cell is created in grid 🔨
    }
}
```

When the grid will show the CellLogs, will get the `CellLogs.xib` and run the `load(params)` method.

### Code

Your controller that will manager a grid need subscriber the protocol `GridViewDelegate`

Minimal example:

```swift
extension ViewController: GridViewDelegate {
    func getCellToRegister() -> [SlotableCell.Type] {
        // we need register cell's class, then, send it's where 🖋
        
        return [CellLogs.self, CellMap.self]
    }
    
    func setup(cell: UICollectionViewCell, params: [String: Any]) {
        // this delegate is called in "collectionView(_:cellForItemAt)" from GridViewController
        // it's useful when we need to setup many cells with same code 🍡
        
        cell.layer.cornerRadius = 10
    }
}
```

Then, we need set a variable to manager a grid and set `ViewController` as a delegate.

Minimal example:

```swift
class ViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    var containerGrid: GridViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the cells to show in grid 📌
        containerGrid!.gridConfiguration = [
            [Slot(cell: CellMap.self, params: [:]), Slot(cell: CellChart.self, params: [:])],
            [Slot(cell: CellLogs.self, params: [:])],
            [Slot(cell: CellCharacter.self, params: ["race": "troll"]), Slot(cell: CellCharacter.self, params: ["race": "elves"]), Slot(cell: CellCharacter.self, params: ["race": "undead"]), Slot(cell: CellCharacter.self, params: ["race": "merfolk"])]
        ]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueGrid" {
            self.containerGrid = (segue.destination as! GridViewController)
            self.containerGrid!.delegate = self
        }
    }
}
```

To understand how to set `gridConfiguration` correctly, read the section "How GridView work?".

# How GridView work?

The GridView **always** show all cells, and set in each cell a proportional size with the `slotWidth` and `slotHeight`.

![](http://i.imgur.com/Z6G8ymq.png)

When GridView will draw a cell, check if have a enough space in first slot. If have, draw. If haven't, check in the second slot, and so on.
