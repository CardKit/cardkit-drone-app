//
//  NameCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/17/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import CardKit

class NameCell: CardDetailTableViewCell, CardDetailCell {
    
    var type: CardDetailTableViewController.CardDetailTypes?
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {    
        let descriptor = card.descriptor
        mainLabel?.text = descriptor.name
    }
    
}
