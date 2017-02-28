//
//  ReturnHome.swift
//  DroneCardKit
//
//  Created by Kyungmin Lee on 2/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class ReturnHome: ExecutableActionCard {
    
    override public func main() {
        guard let drone: DroneToken = self.token(named: "Drone") as? DroneToken else {
            return
        }
        
        let altitude: DCKRelativeAltitude? = self.optionalValue(forInput: "Altitude")
        let speed: DCKSpeed? = self.optionalValue(forInput: "Speed")

        do {
            // return back to the home location
            if !isCancelled {
                try drone.returnHome(atAltitude: altitude, atSpeed: speed, toLand: true)
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
