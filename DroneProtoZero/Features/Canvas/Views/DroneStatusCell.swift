/**
 * Copyright 2018 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

class DroneStatusCell: UITableViewCell, Reusable {
    @IBOutlet weak var connectToDroneButton: UIButton?
    @IBOutlet weak var validateButton: UIButton?
    @IBOutlet weak var executeButton: UIButton?
    @IBOutlet weak var statusLabel: UILabel?
    
    var statusTitle: String = "Unknown"
    var statusDetails: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(DroneStatusCell.connectionStatusChanged), name: DJIHardwareManager.NotificationName.statusUpdated, object: nil)
        
        statusLabel?.isUserInteractionEnabled = true
        statusLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(handleLabelTap)))
        
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
        case let val where val == connectToDroneButton:
            do {
                try DJIHardwareManager.sharedInstance.connect()
            } catch {
                switch error {
                case DJIConnectionError.apiKeyNotSet(let details):
                    displayAlert(title: "Error", details: details)
                case DJIConnectionError.debugIPNotSet(let details):
                    displayAlert(title: "Error", details: details)
                default:
                    displayAlert(title: "Error", details: error.localizedDescription)
                }
                print(error)
            }
        case let val where val == validateButton:
            let _ = Sequencer.shared.validate()
        case let val where val == executeButton:
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
            executeButton?.isEnabled = true
            connectToDroneButton?.isEnabled = false
        default:
            executeButton?.isEnabled = false
            connectToDroneButton?.isEnabled = true
        }
        
        updateStatusLabel(status)
    }
    
    func updateStatusLabel(_ status: ConnectionStatus) {
        statusTitle = "Unknown"
        statusDetails = nil
        
        switch status {
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
            
            statusLabel?.attributedText = attributedString
        } else {
            statusLabel?.text = newStatusLabelText
        }
        
    }
}
