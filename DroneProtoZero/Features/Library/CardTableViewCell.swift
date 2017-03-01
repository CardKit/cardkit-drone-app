//
//  CardTableViewCell.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit
import DroneCardKit

class CardTableViewCell: UITableViewCell, Reusable {
    
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var cardImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(cardDescriptor: ActionCardDescriptor) {
        if let image = UIImage(named: cardDescriptor.name) {
             cardImage.image = image
            label?.isHidden = true
        } else {
            label?.isHidden = false
            label?.text = cardDescriptor.name
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        label?.text = ""
        cardImage.image = nil
    }

}
