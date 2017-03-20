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
import DroneCardKit

class MultipleChoiceCell: CardDetailTableViewCell, CardDetailInputCell, MultipleChoicePopoverDelegate {
    
    @IBOutlet weak var button: UIButton?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var inputSlot: InputSlot?
    var choices: [String] = ["None"]
    var selection: Int = 0 {
        didSet {
            if selection < choices.count {
                button?.setTitle(choices[selection], for: .normal)
            }
        }
    }
    
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
        
        guard let inputSlot = self.inputSlot else {
            return
        }
        
        mainLabel?.text = inputSlot.descriptor.inputDescription
        
        if let inputOptions = DroneCardKit.allInputTypes[inputSlot.descriptor.inputType] as? StringEnumerable.Type {
            self.choices.append(contentsOf: inputOptions.stringValues)
            //select first choice by default
            button?.setTitle(self.choices.first, for: .normal)
        }
    }
    
    // MARK: MultipleChoicePopoverDelegate
    
    func didMakeSelection(selection: Int) {
        self.selection = selection
    }
}
