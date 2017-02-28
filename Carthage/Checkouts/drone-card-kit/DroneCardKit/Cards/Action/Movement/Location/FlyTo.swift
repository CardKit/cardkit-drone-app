//
//  FlyTo.swift
//  DroneCardKit
//
//  Created by Justin Manweiler on 12/2/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class FlyTo: ExecutableActionCard {
    
    override public func main() {
        guard let drone: DroneToken = self.token(named: "Drone") as? DroneToken else {
            return
        }
        
        guard let location: DCKCoordinate2D = self.value(forInput: "Destination") else {
            return
        }
        
        let altitude: DCKRelativeAltitude? = self.optionalValue(forInput: "Altitude")
        let speed: DCKSpeed? = self.optionalValue(forInput: "Speed")
        
        do {
            if !isCancelled {
                try drone.takeOff()
            }
            
            if !isCancelled {
                try drone.fly(to: location, atAltitude: altitude, atSpeed: speed)
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
