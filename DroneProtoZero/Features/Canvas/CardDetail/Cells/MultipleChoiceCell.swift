/**
 * Copyright 2018 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
        self.actionCard = card
        
        guard let inputSlot = self.inputSlot else {
            return
        }
        
        mainLabel?.text = inputSlot.descriptor.inputDescription
        
        if let inputOptions = inputSlot.descriptor.availableOptions() {
            self.choices.append(contentsOf: inputOptions)
            
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
            let inputSlot = self.inputSlot {
            if let val: String = card.value(of: inputSlot) {
                return val
            }
        }
        return ""
    }

    
    // MARK: MultipleChoicePopoverDelegate
    
    func didMakeSelection(selection: Int) {
        self.selection = selection
        
        guard let inputSlot = self.inputSlot,
            let inputOptions = inputSlot.descriptor.availableOptions() else {
                return
        }
        
        let inputValue = inputOptions[selection-1]
        
        let inputTypeString = inputSlot.descriptor.inputType
        var inputCard = inputSlot.descriptor.makeCard()
        
        do {
            switch inputTypeString {
            case String(describing: DCKVideoFramerate.self):
                inputCard = try inputCard.bound(withValue: DCKVideoFramerate(rawValue: inputValue))
            case String(describing: DCKVideoResolution.self):
                inputCard = try inputCard.bound(withValue: DCKVideoResolution(rawValue: inputValue))
            case String(describing: DCKPhotoAspectRatio.self):
                inputCard = try inputCard.bound(withValue: DCKPhotoAspectRatio(rawValue: inputValue))
            case "DCKPhotoBurstCount":
                if let intVal = Int(inputValue) {
                    inputCard = try inputCard.bound(withValue: DCKPhotoBurstCount(rawValue: intVal))
                }
            default:
                break
            }
            
            try actionCard?.bind(with: inputCard, in: inputSlot)
        } catch {
            print("error \(error)")
        }

    }
}
