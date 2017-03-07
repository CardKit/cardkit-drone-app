//
//  CardInputField.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/6/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class CardInputField: UITextField {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bottomBorder: CALayer = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor(hexString: "#C8C7CC").cgColor
        self.layer.addSublayer(bottomBorder)
    }
    

}
