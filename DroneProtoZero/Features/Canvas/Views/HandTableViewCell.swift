//
//  HandTableViewCell.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class HandTableViewCell: UITableViewCell, Reusable {

    var handID: Int = 0
    @IBOutlet weak var collectionView: UICollectionView!
    var isEmpty: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupHand(sectionID: Int) {
        handID = sectionID
        collectionView.isHidden = true
    }
    
    func addCard(card: ActionCardDescriptor) {
        
    }
    
    func showHovering(isHovering: Bool) {
        if isHovering {
            backgroundColor = .green
        } else {
            backgroundColor = .white
        }
        
    }

}
