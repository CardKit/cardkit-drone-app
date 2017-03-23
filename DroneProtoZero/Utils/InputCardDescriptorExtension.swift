//
//  InputCardDescriptorExtension.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/20/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import CardKit
import DroneCardKit

extension InputCardDescriptor {
    func availableOptions() -> [String]? {
        let inputTypeStr = self.inputType
        guard let inputType = DroneCardKit.allInputTypes[inputTypeStr], let enumInputType = inputType as? StringEnumerable.Type else {
            return nil
        }
        return enumInputType.stringValues
    }
}
