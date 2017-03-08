//
//  CardDetailHeaderView.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/2/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class CardDetailHeaderView: UITableViewCell, Reusable {
    
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var endsLabel: UILabel?
    @IBOutlet weak var optionalLabel: UILabel?
    
    var ends: Bool = true {
        didSet {
            if ends {
                endsLabel?.text = "ENDS: YES"
                endsLabel?.textColor = .red
            } else {
                endsLabel?.text = "ENDS: NO"
                endsLabel?.textColor = UIColor.darkText
            }
        }
    }
    
    var optional: Bool = true {
        didSet {
            optionalLabel?.isHidden = false
            if optional {
                optionalLabel?.text = "OPTIONAL"
                optionalLabel?.textColor = UIColor.textHeaderGray
            } else {                
                optionalLabel?.text = "REQUIRED"
                optionalLabel?.textColor = UIColor.red
            }
        }
    }
}
