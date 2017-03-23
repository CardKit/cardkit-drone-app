//
//  CardDetailTableViewCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/2/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

protocol CardDetailCell {
    var type: CardDetailTableViewController.CardDetailTypes? { get set }
    func setupCell(card: ActionCard, indexPath: IndexPath)
}

protocol CardDetailInputCell: CardDetailCell {
    var inputSlot: InputSlot? { get set }
}

class CardDetailTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var frameView: UIView?
    @IBOutlet weak var mainLabel: UILabel?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if self.frameView != nil {
            self.frameView?.layer.cornerRadius = 6.0
        }
    }
    
    // MARK: UITextViewDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let numericalInput = textField as? CardInputField, numericalInput.isNumericalOnly {
            return numericalInput.validateNumericalOnly(inputText: string)
        }
        return true
    }
}
