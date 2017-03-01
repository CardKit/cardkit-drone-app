//
//  CardTableViewCell.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class CardTableViewCell: UITableViewCell, Reusable {
    
    public static let cardWidth: CGFloat = 240.0
    public static let cardHeight: CGFloat = 195.0
    
    @IBOutlet weak var cardView: UIView?
    @IBOutlet weak var label: UILabel?
    
    var cardDescriptor: ActionCardDescriptor?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        cardDescriptor = nil
    }
}
