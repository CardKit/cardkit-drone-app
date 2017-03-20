//
//  MultipleChoiceCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/9/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import UIKit
import CardKit

class MultipleChoiceCell: CardDetailTableViewCell, CardDetailInputCell {
    
    @IBOutlet weak var button: UIButton?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var inputSlot: InputSlot?
    var selection: Int? = 0
    
    var section: Int? {
        didSet {
            guard let button = button,
            let section = section else {
                return
            }
            button.tag = section
        }
    }
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
//        let inputSlot = cardDescriptor.inputSlots[inputIndex]
//        
//        mainLabel?.text = inputSlot.descriptor.inputDescription
//        
//        self.section = indexPath.section
//        //TODO: these need to come from somewhere
//        let choices = ["None", "Normal", "Fine", "Excellent"]
//        //TODO: set selection based on data in card
//        if let selectionIndex = selection {
//            button?.setTitle(choices[selectionIndex], for: .normal)
//        }
    }
    
}
