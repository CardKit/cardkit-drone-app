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
    var actionCard: ActionCard?
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
            
            let selectedOption = getSelectedInputOption()
            
            if selectedOption == "" {
                //no selection, so select none
                button?.setTitle(self.choices.first, for: .normal)
            } else {
                if let selectedIndex = self.choices.index(of: selectedOption) {
                    self.selection = selectedIndex
                }                
            }
        }
    }
    
    // MARK: Instance methods
    
    func getSelectedInputOption() -> String {
        if let card = self.actionCard,
            let inputSlot = self.inputSlot,
            let inputSlotBinding = card.inputBindings[inputSlot] {
            switch inputSlotBinding {
            case .boundToInputCard(let inputCard):
                switch inputCard.boundData {
                case .bound(let json):
                    return json.description
                default:
                    return ""
                }
            default:
                return ""
            }
        }
        return ""
    }

    
    // MARK: MultipleChoicePopoverDelegate
    
    func didMakeSelection(selection: Int) {
        self.selection = selection
        
        if let inputSlot = self.inputSlot,
            let inputType = DroneCardKit.allInputTypes[inputSlot.descriptor.inputType],
            let inputOptions = inputSlot.descriptor.availableOptions() {
            
            do {
                if selection == 0 {
                    actionCard?.unbind(inputSlot)
                } else {
                    let index = selection - 1
                    let inputCard = try inputSlot.descriptor <- inputType.init(json: inputOptions[index].toJSON())
                    try actionCard?.bind(with: inputCard, in: inputSlot)
                }
            } catch {
                print("error \(error)")
            }
        }
    }
}
