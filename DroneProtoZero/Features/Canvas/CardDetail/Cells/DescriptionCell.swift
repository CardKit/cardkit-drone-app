//
//  DescriptionCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/17/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import CardKit

class DescriptionCell: CardDetailTableViewCell, CardDetailCell {
    
    var type: CardDetailTableViewController.CardDetailTypes?
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        let descriptor = card.descriptor

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
