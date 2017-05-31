//
//  CellCharacter.swift
//  Example-tvOS
//
//  Created by Bruno Macabeus Aquino on 28/04/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit
import GridView

class CellCharacter: UICollectionViewCell, SlotableCell {
    
    @IBOutlet weak var image: UIImageView!
    static let slotWidth = 1
    static let slotHeight = 1
    var params: [String : Any] = [:]
    
    func load(params: [String: Any]) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView!.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView!.addSubview(blurEffectView)
        
        //
        let paramRace = params["race"] as? String
        
        switch paramRace { // imagens from the amazing open source game Battle for Wesnoth
        case "undead"?:
            backgroundView!.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "undead"))
            image.image = #imageLiteral(resourceName: "undead")
        case "elves"?:
            backgroundView!.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "elves"))
            image.image = #imageLiteral(resourceName: "elves")
        case "merfolk"?:
            backgroundView!.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "merfolk"))
            image.image = #imageLiteral(resourceName: "merfolk")
        case "troll"?:
            backgroundView!.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "troll"))
            image.image = #imageLiteral(resourceName: "troll")
        default:
            print("invalid race: \(paramRace ?? "nil")")
        }
        
        image.contentMode = .topRight
    }
    
}
