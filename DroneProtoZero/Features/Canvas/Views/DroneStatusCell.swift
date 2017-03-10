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
        
        updateStatus(status: DJIHardwareManager.sharedInstance.status)
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
            let _ = Sequencer.shared.validate()
        case executeButton:
            do {
                try Sequencer.shared.execute()
            } catch {
                switch error {
                case SequencerError.failedToDetectHardwareOnDrone(let details):
                    displayAlert(title: "Error", details: details)
                case SequencerError.failiedToRetrieveHardwareManager(let details):
                    displayAlert(title: "Error", details: details)
                default:
                    displayAlert(title: "Error", details: error.localizedDescription)
                }
            }
        default:
            break
        }
    }
    
    // MARK: - Tap Gesture Recognizers
    func handleLabelTap() {
        if let details = statusDetails {
            displayAlert(title: statusTitle, details: details)
        }
    }
    
    // MARK: - Notification Handlers
    func connectionStatusChanged(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
            let connectionStatus = userInfo[DJIHardwareManager.NotificationInfoKey.connectionStatus.rawValue] as? ConnectionStatus else { return }
        
        updateStatus(status: connectionStatus)
    }
    
    // MARK: - Helper Functions
    func displayAlert(title: String, details: String) {
        let alert = UIAlertController(title: title, message: details, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    func updateStatus(status: ConnectionStatus) {
        switch status {
        case .connectionSuccessful(_):
            executeButton.isEnabled = true
        default:
            executeButton.isEnabled = false
        }
        
        updateStatusLabel(status)
    }
    
    func updateStatusLabel(_ status: ConnectionStatus) {
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
        
        let newStatusLabelText = "Status: \(statusTitle)"
        if let _ = statusDetails {
            let attributedString = NSMutableAttributedString(string: newStatusLabelText, attributes: [:])
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.cornflowerBlue, range: NSRange(location:8, length:newStatusLabelText.characters.count-8))
            
            statusLabel.attributedText = attributedString
        } else {
            statusLabel.text = newStatusLabelText
        }
        
    }
}
