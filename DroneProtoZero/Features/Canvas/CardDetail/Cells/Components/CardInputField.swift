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

class CardInputField: UITextField {

    var isNumericalOnly: Bool = true
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bottomBorder: CALayer = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.placeholderGray.cgColor
        self.layer.addSublayer(bottomBorder)
    }
    
    func validateNumericalOnly(inputText: String) -> Bool {
        //http://stackoverflow.com/questions/30973044/how-to-restrict-uitextfield-to-take-only-numbers-in-swift
        
        let numberSet = CharacterSet(charactersIn: "0123456789-.").inverted
        let stringBySet = inputText.components(separatedBy: numberSet)
        let stringFiltered = stringBySet.joined(separator: "")
        return inputText == stringFiltered
        
    }
    
}
