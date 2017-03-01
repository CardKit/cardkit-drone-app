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
    
    public static let cardWidth: CGFloat = 182.0
    public static let cardHeight: CGFloat = 200.0
    
    @IBOutlet weak var cardView: UIView?
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var cardImage: UIImageView!
    
    var cardDescriptor: ActionCardDescriptor?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(cardDescriptor: ActionCardDescriptor) {
        if let image = UIImage(named: cardDescriptor.name) {
            cardImage.image = image
            label?.isHidden = true
            cardView?.backgroundColor = .clear
        } else {
            label?.isHidden = false
            label?.text = cardDescriptor.name
            cardView?.backgroundColor = .athensGray
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        label?.text = ""
        cardImage.image = nil
         cardDescriptor = nil
    }
}
