//
//  DroneStatusCell.swift
//  DroneProtoZero
//
//  Created by boland on 2/28/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class DroneStatusCell: UITableViewCell, Reusable {
    @IBOutlet weak var connectToDroneButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var executeButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        switch sender {
        case connectToDroneButton:
            do {
                try DJIHardwareManager.sharedInstance.connect()
            } catch {
                print(error)
            }
        case validateButton:
            print("validate button tapped")
        case executeButton:
            print("execute button tapped")
        default:
            break
        }
    }
}
