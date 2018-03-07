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

class CardTableViewCell: UITableViewCell, Reusable {
    
    public static let cardWidth: CGFloat = 182.0
    public static let cardHeight: CGFloat = 200.0
    
    @IBOutlet weak var cardView: UIView?
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var cardImage: UIImageView!
    
    var cardDescriptor: ActionCardDescriptor?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(cardDescriptor: ActionCardDescriptor) {
        self.cardDescriptor = cardDescriptor
        if let image = UIImage(named: cardDescriptor.name) {
            cardImage.image = image
            label?.isHidden = true
            cardView?.backgroundColor = .clear
        } else {
            label?.isHidden = false
            label?.text = cardDescriptor.name
            cardView?.backgroundColor = .athensGray
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        label?.text = ""
        cardImage.image = nil
         cardDescriptor = nil
    }
}
