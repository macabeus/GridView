[![Version](https://img.shields.io/cocoapods/v/GridView.svg?style=flat)](http://cocoapods.org/pods/GridView)
[![License](https://img.shields.io/cocoapods/l/GridView.svg?style=flat)](http://cocoapods.org/pods/GridView)
[![Platform](https://img.shields.io/cocoapods/p/GridView.svg?style=flat)](http://cocoapods.org/pods/GridView)

# GridView
📜  Amazing grid view in your tvOS/iOS app

![](http://i.imgur.com/Zn3c7bD.png)
![](http://i.imgur.com/0fccFX3.png)

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

1. Create a *Container View*
2. Change the *View Controller* for  *Collection View Controller*
3. Set `GridViewController` as a custom class

### Create a cell

To display a cell in grid, the cell need be a `UICollectionViewCell` and subscriber the protocol `SlotableCell`.<br>
And, you need create a xib file with *Collection View Cell*. The xib, and cell's indentifier in xib file, **need** have the same name of the class.

Minimal example:

```swift
import UIKit
import GridView

class CellLogs: UICollectionViewCell, SlotableCell {
 
    static let slotWidth = 1 // size of cell in grid 📏
    static let slotHeight = 1 // size of cell in grid 📐
    var slotParams: [String : Any] = [:]

    func load() { 
        // this method if called when a cell is created in grid 🔨
    }
}
```

When the grid will show the `CellLogs`, will get the `CellLogs.xib` and run the `load(params)` method.

### Code

Your controller that will manager a grid need subscriber the protocol `GridViewDelegate`

Minimal example:

```swift
extension ViewController: GridViewDelegate {
    func getCellToRegister() -> [SlotableCell.Type] {
        // we need register cell's class, then, send it's where 🖋
        
        return [CellLogs.self, CellMap.self]
        
        // if do you want list all classes that subscreber the SlotableCell protocol, you can read use this gist: https://gist.github.com/brunomacabeusbr/eea343bb9119b96eed3393e41dcda0c9 💜
    }
    
    func setup(cell: SlotableCell) {
        // this delegate is called in "collectionView(_:cellForItemAt)" from GridViewController
        // it's useful when we need to setup many cells with same code 🍡
        
        // for example, connect to server, if a cell need
        if let cellRealTime = cell as? CellRealTimeProtocol {
            cellRealTime.connect()
        }
        
        // layout
        (cell as? UICollectionViewCell)?.layer.cornerRadius = 10
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
        containerGrid!.gridConfiguration = GridConfiguration.create(slots: Slots(slots: [
            [Slot(cell: CellMap.self, params: [:]), Slot(cell: CellChart.self, params: [:])],
            [Slot(cell: CellLogs.self, params: [:])],
            [Slot(cell: CellCharacter.self, params: ["race": "troll"]), Slot(cell: CellCharacter.self, params: ["race": "elves"]), Slot(cell: CellCharacter.self, params: ["race": "undead"]), Slot(cell: CellCharacter.self, params: ["race": "merfolk"])]
            ])
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueGrid" {
            self.containerGrid = (segue.destination as! GridViewController)
            self.containerGrid!.delegate = self
        }
    }
}
```

To understand how to set layout with `gridConfiguration` correctly, read the section "How GridView work?".

### params

When you create a `Slot`, you set a cell of this slot, and also **params** of this slot. For example:

```swift
Slot(cell: CellCharacter.self, params: ["race": "undead"])
```

The value of `params` is set in attribute `slotParams` of `SlotableCell`.

Example of use:

```swift
class CellCharacter: UICollectionViewCell, SlotableCell {
    
    ...
    var slotParams: [String : Any] = [:]

    func load() {
        let paramRace = slotParams["race"] as? String
    
        switch paramRace {
        case "undead"?:
            image.image = UIImage(named: "undead")!
        case "elves"?:
            image.image = UIImage(named: "elves")!
        case "troll"?:
            image.image = UIImage(named: "troll")!
        default:
            print("invalid race: \(paramRace ?? "nil")")
        }
    }
}
```

### How to reload a grid?

If you already a set a value to `gridConfiguration`, and want set a new value, to reload a grid use the method `reloadGrid()`.

```swift
containerGrid!.gridConfiguration = [ ... ] // new values for my awesome grid
containerGrid!.reloadGrid() // reload it
```

# How GridView work?

The GridView **always** show all cells, and set in each cell a proportional size with the `slotWidth` and `slotHeight`.

![](http://i.imgur.com/Z6G8ymq.png)

When GridView will draw a cell, check if have a enough space in first slot. If have, draw. If haven't, check in the second slot, and so on.<br>
The total of columns is calculated at runtime.

---

**Maintainer**:

> [macabeus](http://macalogs.com.br/) &nbsp;&middot;&nbsp;
> GitHub [@macabeus](https://github.com/macabeus)
