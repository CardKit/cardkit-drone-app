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

class CardDetailHeaderView: UIView {
    
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var endsLabel: UILabel?
    @IBOutlet weak var optionalLabel: UILabel?
    
    var ends: Bool = true {
        didSet {
            if ends {
                endsLabel?.text = "ENDS: YES"
                endsLabel?.textColor = .red
            } else {
                endsLabel?.text = "ENDS: NO"
                endsLabel?.textColor = UIColor.darkText
            }
        }
    }
    
    var optional: Bool = true {
        didSet {
            optionalLabel?.isHidden = false
            if optional {
                optionalLabel?.text = "OPTIONAL"
                optionalLabel?.textColor = UIColor.textHeaderGray
            } else {                
                optionalLabel?.text = "REQUIRED"
                optionalLabel?.textColor = UIColor.red
            }
        }
    }
}
