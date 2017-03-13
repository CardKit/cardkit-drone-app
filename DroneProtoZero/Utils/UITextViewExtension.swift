//
//  UITextViewExtension.swift
//  DroneProtoZero
//
//  Created by ismails on 3/10/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

extension UITextView {
    func scrollToBottom() {
        let range = NSMakeRange(self.text.characters.count - 1, 0)
        self.scrollRangeToVisible(range)
    }
}
