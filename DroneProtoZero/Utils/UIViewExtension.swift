//
//  UIView.swift
//  DroneProtoZero
//
//  Created by ismails on 3/9/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        
        while let parent = parentResponder  {
            parentResponder = parent.next
            
            if parentResponder is UIViewController {
                return parentResponder as? UIViewController
            }
        }
        
        return nil
    }
}
