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
    
    @IBOutlet weak var mainLabel: UILabel?
    
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
    
    override func setupCell(cardDescriptor: ActionCardDescriptor) {
        super.setupCell(cardDescriptor: cardDescriptor)
        
        mainLabel?.text = cardDescriptor.name
        print("token slots \(cardDescriptor.tokenSlots)")
    }
    
}
