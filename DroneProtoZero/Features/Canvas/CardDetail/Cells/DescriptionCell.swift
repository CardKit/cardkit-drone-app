//
//  DescriptionCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/17/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import Foundation
import CardKit
import DroneCardKit

class DescriptionCell: CardDetailTableViewCell, CardDetailCell {
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var actionCard: ActionCard?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        let descriptor = card.descriptor
        self.actionCard = card
        
        guard let type = self.type else {
            return
        }
        
        switch type {
        case .descriptionCell:
            mainLabel?.text = descriptor.assetCatalog.textualDescription //description
        case .endDetailsCell:
            mainLabel?.text = descriptor.endDescription
        case .outputsCell:
            mainLabel?.text = descriptor.yieldDescription
        default:
            return
        }
    }
}
