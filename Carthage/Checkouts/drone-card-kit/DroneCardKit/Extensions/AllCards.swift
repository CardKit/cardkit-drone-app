//
//  AllCards.swift
//  DroneCardKit
//
//  Created by Kristina M Brimijoin on 2/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import CardKit

extension DroneCardKit {
    
    public func allCards() -> [ActionCardDescriptor] {
        return [
            DroneCardKit.Action.Movement.Simple.FlyForward,
            DroneCardKit.Action.Movement.Simple.Hover,
            DroneCardKit.Action.Movement.Simple.Land
        ]
    }    
}
