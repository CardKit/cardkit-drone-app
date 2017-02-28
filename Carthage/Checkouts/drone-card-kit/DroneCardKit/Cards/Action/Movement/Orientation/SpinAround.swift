//
//  SpinAround.swift
//  DroneCardKit
//
//  Created by Kyungmin Lee on 2/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class SpinAround: ExecutableActionCard {
    
    override public func main() {
        guard let drone: DroneToken = self.token(named: "Drone") as? DroneToken,
            let yaw: DCKAngle = self.value(forInput: "Angle")
            else {
                return
        }
        
        let altitude: DCKRelativeAltitude? = self.optionalValue(forInput: "Altitude")
        let angularSpeed: DCKAngularVelocity? = self.optionalValue(forInput: "AngularSpeed")
        
        do {
            // take of to the provided altitude
            if !isCancelled && altitude != nil {
                try drone.takeOff(at: altitude)
            }
            
            // spin around (NOT WORKING YET)
            if !isCancelled {
                try drone.spinAround(toYawAngle: yaw, atAngularSpeed: angularSpeed)
            }
        } catch {
            self.error = error
            
            if !isCancelled {
                cancel()
            }
        }
    }
    
    override public func cancel() {
        guard let drone: DroneToken = self.token(named: "Drone") as? DroneToken else {
            return
        }
        
        do {
            try drone.land()
        } catch {
            if self.error == nil {
                self.error = error
            }
        }
    }
    
}
