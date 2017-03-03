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
}
