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
            case String(describing: Bool.self):
                value =  inputValue.lowercased() == "true" ? true : false
            default:
                break
            }
            
            if let valueUR = value {
                let inputCard = try inputSlot.descriptor.makeCard() <- valueUR
                try actionCard?.bind(with: inputCard, in: inputSlot)
            }
        } catch {
            print("error \(error)")
        }
    }
}

//extension Bool: JSONEncodable, JSONDecodable { }
