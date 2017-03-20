//
//  StandardInputCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/17/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import UIKit
import CardKit

class StandardInputCell: CardDetailTableViewCell, CardDetailInputCell {
    
    @IBOutlet weak var input: UITextField?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var inputSlot: InputSlot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        input?.keyboardType = .decimalPad
    }
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        
        if let slot = inputSlot {
            mainLabel?.text = "\(slot.descriptor.inputDescription)"
        }
        
        input?.keyboardType = .decimalPad
    }
    
}
