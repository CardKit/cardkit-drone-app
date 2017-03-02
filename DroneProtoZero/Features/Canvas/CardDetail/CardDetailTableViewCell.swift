//
//  CardDetailTableViewCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/2/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class CardDetailTableViewCell: UITableViewCell, Reusable {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(cardDescriptor: ActionCardDescriptor) {
        
    }

}

class NameCell: CardDetailTableViewCell {
    
    @IBOutlet weak var endsLabel: UILabel?
    
    override func setupCell(cardDescriptor: ActionCardDescriptor) {
        super.setupCell(cardDescriptor: cardDescriptor)
        
        if cardDescriptor.ends {
            endsLabel?.text = "ENDS: YES"
            endsLabel?.textColor = .red
        } else {
            endsLabel?.text = "ENDS: NO"
            endsLabel?.textColor = UIColor.darkText
        }
    }
    
}
