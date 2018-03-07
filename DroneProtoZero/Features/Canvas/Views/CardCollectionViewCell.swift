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
import CardKit

class CardCollectionViewCell: UICollectionViewCell, Reusable {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var label: UILabel?
    var cardDescriptor: CardDescriptor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        cardImage.image = nil
        label?.text = "Card Name"
        label?.isHidden = true
        cardImage.backgroundColor = .white
        cardDescriptor = nil
    }
    
    func setupCell(card: CardDescriptor) {
        cardDescriptor = card
        if let cardDescriptor = self.cardDescriptor, let image = UIImage(named: cardDescriptor.name) {
            cardImage.image = image
            cardImage.backgroundColor = .white
            label?.isHidden = true
        } else {
            label?.isHidden = false
            label?.text = cardDescriptor?.name
            cardImage.backgroundColor = .athensGray
        }
    }
}
