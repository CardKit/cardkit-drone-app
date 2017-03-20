//
//  BinaryChoiceCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/17/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import Freddy
import UIKit
import CardKit
import DroneCardKit

class BinaryChoiceCell: CardDetailTableViewCell, CardDetailInputCell {
    
    @IBOutlet weak var segControl: UISegmentedControl?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var inputSlot: InputSlot?
    var actionCard: ActionCard?
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        
        self.actionCard = card
        
        guard let inputSlot = self.inputSlot else {
            return
        }
        mainLabel?.text = "\(inputSlot.name)"
        
        
        
        //get which selection is pre-set
        let selectedOption: String = getSelectedInputOption()

        //populate segments and select the selected one
        if let inputOptions = inputSlot.descriptor.availableOptions() {
            if let segments = segControl?.numberOfSegments {
                for i in 0...segments-1 {
                    if i < inputOptions.count {
                        segControl?.setTitle(inputOptions[i], forSegmentAt: i)
                        if inputOptions[i] == selectedOption {
                            segControl?.selectedSegmentIndex = i
                        }
                    }
                }
            }
        }
        
        segControl?.addTarget(self, action: #selector(selectionChanged(segControl:)), for: .valueChanged)
    }
    
    func getSelectedInputOption() -> String {
        if let card = self.actionCard,
            let inputSlot = self.inputSlot {
            if let val: String = card.value(of: inputSlot) {
                return val
            }
        }
        return ""
    }
    
    func selectionChanged(segControl: UISegmentedControl) {
        
        if let inputSlot = self.inputSlot,
            let inputType = DroneCardKit.allInputTypes[inputSlot.descriptor.inputType],
            let inputOptions = inputSlot.descriptor.availableOptions() {
            
            do {
                let inputCard = try inputSlot.descriptor <- inputType.init(json: inputOptions[segControl.selectedSegmentIndex].toJSON())
                try actionCard?.bind(with: inputCard, in: inputSlot)
            } catch {
                print("error \(error)")
            }
        }
    }
}
