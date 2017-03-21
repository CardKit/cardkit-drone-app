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
        if let inputOptions = inputSlot.descriptor.availableOptions(), let segments = segControl?.numberOfSegments {
            for i in 0...segments-1 {
                if i >= inputOptions.count { break }
                
                segControl?.setTitle(inputOptions[i], forSegmentAt: i)
                
                if inputOptions[i].lowercased() == selectedOption.lowercased() {
                    segControl?.selectedSegmentIndex = i
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
        guard let inputSlot = self.inputSlot,
            let inputOptions = inputSlot.descriptor.availableOptions() else {
                return
        }
        
        let inputValue = inputOptions[segControl.selectedSegmentIndex]
        
        let inputTypeString = inputSlot.descriptor.inputType
        var value: Any?
        
        do {
            switch inputTypeString {
            case String(describing: DCKRotationDirection.self):
                value = DCKRotationDirection(rawValue: inputValue)
            case String(describing: Bool.self):
                value =  inputValue.lowercased() == "true" ? true : false
            default:
                break
            }
            
            if let valueUR = value {
                let inputCard = try inputSlot.descriptor <- valueUR
                try actionCard?.bind(with: inputCard, in: inputSlot)
            }
        } catch {
            print("error \(error)")
        }
    }
}

//extension Bool: JSONEncodable, JSONDecodable { }
