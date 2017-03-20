//
//  BinaryChoiceCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/17/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import UIKit
import CardKit
import DroneCardKit

class BinaryChoiceCell: CardDetailTableViewCell, CardDetailInputCell {
    
    @IBOutlet weak var segControl: UISegmentedControl?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var inputSlot: InputSlot?
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        guard let inputSlot = self.inputSlot else {
            return
        }
        mainLabel?.text = "\(inputSlot.name)"
        
        let descriptor = inputSlot.descriptor
        
        if let inputOptions = DroneCardKit.allInputTypes[descriptor.inputType] as? StringEnumerable.Type {
            let inputOptionsStrings = inputOptions.stringValues
            if let segments = segControl?.numberOfSegments {
                for i in 0...segments-1 {
                    if i < inputOptionsStrings.count {
                        segControl?.setTitle(inputOptionsStrings[i], forSegmentAt: i)
                    }
                }
            }
        }
    }
}
