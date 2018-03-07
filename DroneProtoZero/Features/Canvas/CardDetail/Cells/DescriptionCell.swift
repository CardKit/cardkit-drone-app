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
