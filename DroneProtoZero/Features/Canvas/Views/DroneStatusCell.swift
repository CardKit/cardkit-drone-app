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
    
    var statusTitle: String = "Unknown"
    var statusDetails: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(DroneStatusCell.connectionStatusChanged), name: DJIHardwareManager.NotificationName.statusUpdated, object: nil)
        
        statusLabel.isUserInteractionEnabled = true
        statusLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(handleLabelTap)))
        
        updateStatusLabel(status: DJIHardwareManager.sharedInstance.status)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: LibraryViewController.NotificationName.displayLogsView, object: nil, userInfo: nil)
        
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
    
    // MARK: - Tap Gesture Recognizers
    func handleLabelTap() {
        if let details = statusDetails {
            let alert = UIAlertController(title: statusTitle, message: details, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.parentViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Notification Handlers
    func connectionStatusChanged(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
            let connectionStatus = userInfo[DJIHardwareManager.NotificationInfoKey.connectionStatus.rawValue] as? ConnectionStatus else { return }
        
        updateStatusLabel(status: connectionStatus)
    }
    
    func updateStatusLabel(status: ConnectionStatus) {
        statusTitle = "Unknown"
        statusDetails = nil
        
        switch status {
        case .unknown:
            statusTitle = "Unknown"
        case .failedToConnectToSDK(let details):
            statusTitle = "Failed to Connect to SDK"
            statusDetails = details
        case .disconnected(let details):
            statusTitle = "Disconnected"
            statusDetails = details
        case .searchingForProducts(let details):
            statusTitle = "Searching for Products"
            statusDetails = details
        case .connectionSuccessful(let details):
            statusTitle = "Connection Successful"
            statusDetails = details
        }
        
        statusLabel.text = "Status: \(statusTitle)"
    }
}
