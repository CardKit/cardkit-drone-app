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

import UIKit
import CardKit

protocol CardDetailCell {
    var type: CardDetailTableViewController.CardDetailTypes? { get set }
    func setupCell(card: ActionCard, indexPath: IndexPath)
}

protocol CardDetailInputCell: CardDetailCell {
    var inputSlot: InputSlot? { get set }
}

class CardDetailTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var frameView: UIView?
    @IBOutlet weak var mainLabel: UILabel?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if self.frameView != nil {
            self.frameView?.layer.cornerRadius = 6.0
        }
    }
    
    // MARK: UITextViewDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let numericalInput = textField as? CardInputField, numericalInput.isNumericalOnly {
            return numericalInput.validateNumericalOnly(inputText: string)
        }
        return true
    }
}
