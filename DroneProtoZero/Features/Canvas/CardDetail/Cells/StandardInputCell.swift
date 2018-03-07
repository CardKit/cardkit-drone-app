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

class StandardInputCell: CardDetailTableViewCell, CardDetailInputCell {
    
    @IBOutlet weak var input: UITextField?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var inputSlot: InputSlot?
    var actionCard: ActionCard?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        input?.keyboardType = .numberPad
    }
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        
        self.actionCard = card
        
        if let slot = inputSlot {
            mainLabel?.text = "\(slot.descriptor.inputDescription)"
        }
        
        //TODO: set this based on input type
        input?.keyboardType = .numberPad
        
        input?.addTarget(self, action: #selector(inputTextChanged), for: .editingChanged)
        
        input?.text = getSelectedInputOption()
    }
    
    //swiftlint:disable:next cyclomatic_complexity
    func getSelectedInputOption() -> String {
        guard let card = self.actionCard,
            let inputSlot = self.inputSlot else {
                return ""
        }
        
        let inputTypeString = inputSlot.descriptor.inputType
        
        var stringVal = ""
        
        switch inputTypeString {
        case String(describing: DCKRelativeAltitude.self):
            guard let inputTypeObj: DCKRelativeAltitude = card.value(of: inputSlot) else { break }
            stringVal = String(inputTypeObj.metersAboveGroundAtTakeoff)
        case String(describing: DCKDistance.self):
            guard let inputTypeObj: DCKDistance = card.value(of: inputSlot) else { break }
            stringVal = String(inputTypeObj.meters)
        case String(describing: DCKSpeed.self):
            guard let inputTypeObj: DCKSpeed = card.value(of: inputSlot) else { break }
            stringVal = String(inputTypeObj.metersPerSecond)
        case String(describing: DCKAngularVelocity.self):
            guard let inputTypeObj: DCKAngularVelocity = card.value(of: inputSlot) else { break }
            stringVal = String(inputTypeObj.degreesPerSecond)
        case String(describing: DCKAngle.self):
            guard let inputTypeObj: DCKAngle = card.value(of: inputSlot) else { break }
            stringVal = String(inputTypeObj.degrees)
        case String(describing: Double.self):
            guard let inputTypeObj: Double = card.value(of: inputSlot) else { break }
            stringVal = String(inputTypeObj)
        default:
            break
        }

        return stringVal
    }
    
    func inputTextChanged() {
        
        guard let inputSlot = self.inputSlot,
            let inputValueString = input?.text,
            let inputValue = Double(inputValueString) else {
                return
        }
        
        let inputTypeString = inputSlot.descriptor.inputType
        var value: Any?
        
        switch inputTypeString {
        case String(describing: DCKRelativeAltitude.self):
            value = DCKRelativeAltitude(metersAboveGroundAtTakeoff: inputValue)
        case String(describing: DCKDistance.self):
            value = DCKDistance(meters: inputValue)
        case String(describing: DCKSpeed.self):
            value = DCKSpeed(metersPerSecond: inputValue)
        case String(describing: DCKAngularVelocity.self):
            value = DCKAngularVelocity(degreesPerSecond: inputValue)
        case String(describing: DCKAngle.self):
            value = DCKAngle(degrees: inputValue)
        case String(describing: Double.self):
            value = inputValue
        default:
            break
        }
        
        if let valueUR = value {
            do {
                let inputCard = try inputSlot.descriptor <- valueUR
                try actionCard?.bind(with: inputCard, in: inputSlot)
            } catch {
                print("error \(error)")
            }
        }
    }
    
}
