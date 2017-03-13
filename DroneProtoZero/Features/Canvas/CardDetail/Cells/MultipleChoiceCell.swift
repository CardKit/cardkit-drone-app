//
//  MultipleChoiceCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/9/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import UIKit

class MultipleChoiceCell: CardDetailTableViewCell {
    
    @IBOutlet weak var button: UIButton?
    
    var selection: Int? = 0
    
    var section: Int? {
        didSet {
            guard let button = button,
            let section = section else {
                return
            }
            button.tag = section
        }
    }
    
}
