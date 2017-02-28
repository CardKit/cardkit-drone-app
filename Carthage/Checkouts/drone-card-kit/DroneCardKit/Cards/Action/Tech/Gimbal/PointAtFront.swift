//
//  PointAtFront.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 1/30/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class PointAtFront: ExecutableActionCard {
    override public func main() {
        guard let gimbal: GimbalToken = self.token(named: "Gimbal") as? GimbalToken else {
            return
        }
        
        do {
            if !isCancelled {
                try gimbal.orient(to: .facingForward)
            }
        } catch {
            self.error = error
            
            if !isCancelled {
                cancel()
            }
        }
    }
    
    override public func cancel() {
        // gimbal rotations cannot be cancelled
    }
}
