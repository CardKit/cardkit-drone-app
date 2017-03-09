//
//  CardCollectionViewCell.swift
//  DroneProtoZero
//
//  Created by boland on 3/3/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class CardCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var label: UILabel?
    var cardDescriptor: CardDescriptor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(card: CardDescriptor) {
        cardDescriptor = card
        print("card image to load \(self.cardDescriptor)")
        if let cardDescriptor = self.cardDescriptor, let image = UIImage(named: cardDescriptor.name) {
            cardImage.image = image
            cardImage.backgroundColor = .white
            label?.isHidden = true
        } else {
            label?.isHidden = false
            label?.text = cardDescriptor?.name
            cardImage.backgroundColor = .athensGray
        }
    }
}
