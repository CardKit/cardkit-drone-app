//
//  CardInputField.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/6/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

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
