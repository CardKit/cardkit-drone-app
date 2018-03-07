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

protocol CanvasStepHeaderDelegate: class {
    func removeStepSection(for section: Int)
}

class CanvasStepHeaderView: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var removeSeps: UIButton!
    weak var delegate: CanvasStepHeaderDelegate?
    var sectionID: Int = 0
    
    func setupHeader(section: Int, delegate: CanvasStepHeaderDelegate) {
        headerLabel.text = createSectionName(from: section)
        sectionID = section
        if section == CanvasSection.steps.rawValue {
            removeSeps.isHidden = true
        } else {
            removeSeps.addTarget(self, action: #selector(CanvasStepHeaderView.removeStepSectionButtonPressed(sender:)), for: UIControlEvents.touchUpInside)
            self.delegate = delegate
        }
    }
    
    func removeStepSectionButtonPressed(sender: UIButton) {
        delegate?.removeStepSection(for: sectionID)
    }
    
    func createSectionName(from secID: Int) -> String {
        let trueSection = (secID - CanvasSection.steps.rawValue) + 1
        let newString = NSLocalizedString("STEP_TITLE", comment: "Name of Step")
        return String.localizedStringWithFormat(newString, "\(trueSection)")
    }

}
