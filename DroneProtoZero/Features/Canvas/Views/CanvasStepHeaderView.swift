//
//  CanvasStepHeaderView.swift
//  DroneProtoZero
//
//  Created by boland on 3/1/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

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
