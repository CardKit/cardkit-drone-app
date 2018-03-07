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

import Foundation
import CardKit
import UIKit
import DroneCardKit

class NameCell: CardDetailTableViewCell, CardDetailCell {
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var actionCard: ActionCard?
    
    @IBOutlet weak var hardwareStackview: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        self.actionCard = card
        let descriptor = card.descriptor
        mainLabel?.text = descriptor.name
        
        updateTokens()
    }
    
    func updateTokens() {
        // clearing all items in a view before we re add tokens
        for arrangedSubView in hardwareStackview.arrangedSubviews {
            hardwareStackview.removeArrangedSubview(arrangedSubView)
            arrangedSubView.removeFromSuperview()
        }
        
        // creating a view that fills up the remaining space so we can force the items to be right aligned
        let stretchingView = UIView()
        stretchingView.setContentHuggingPriority(1, for: .horizontal)
        stretchingView.backgroundColor = .clear
        stretchingView.translatesAutoresizingMaskIntoConstraints = false
        hardwareStackview.addArrangedSubview(stretchingView)
        
        // adding tokens one by one to the stackview with witdth and height constraints
        guard let actionCard = actionCard else { return }
        for token in actionCard.descriptor.tokenSlots {
            let tokenName = token.name
            var imageName = "token-empty"
            
            switch tokenName {
            case DroneCardKit.TokenSlotNames.drone.rawValue:
                imageName = "token-drone"
            case DroneCardKit.TokenSlotNames.camera.rawValue:
                imageName = "token-camera"
            case DroneCardKit.TokenSlotNames.gimbal.rawValue:
                imageName = "token-gimbal"
            case DroneCardKit.TokenSlotNames.telemetry.rawValue:
                imageName = "token-telemetry"
            default:
                break
            }
            
            let image = UIImage(named: imageName+".pdf")
            let imageView = UIImageView(image: image)
            
            hardwareStackview.addArrangedSubview(imageView)
            
            self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
            self.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        }
        
        self.updateConstraints()
    }
    
}
