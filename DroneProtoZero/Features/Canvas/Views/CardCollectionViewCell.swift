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
    var cardDescriptor: ActionCardDescriptor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(card: ActionCardDescriptor) {
        cardDescriptor = card
        print("card image to load \(self.cardDescriptor)")
        if let cardDescriptor = self.cardDescriptor, let image = UIImage(named: cardDescriptor.name) {
            cardImage.image = image
        } else {
            cardImage.backgroundColor = .athensGray
        }
    }
}
