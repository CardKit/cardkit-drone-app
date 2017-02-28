//
//  Land.swift
//  DroneCardKit
//
//  Created by ismails on 12/7/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class Land: ExecutableActionCard {
    
    override public func main() {
        guard let drone: DroneToken = self.token(named: "Drone") as? DroneToken else {
            return
        }
        
        let dckSpeed: DCKSpeed? = self.optionalValue(forInput: "Speed")
        
        do {
            // note: DJI drones will always land at their default speed: ~3 m/s. 
            // The speed parameter cannot be used when changing altitude.
            // It can only be used when flying to a location. (for DJI drones)
            
            if let speed = dckSpeed, let currentLocation = drone.currentLocation {
                if !isCancelled {
                    let altitude = DCKRelativeAltitude(metersAboveGroundAtTakeoff: 1.0)
                    try drone.fly(to: currentLocation, atYaw: nil, atAltitude: altitude, atSpeed: speed)
                }
            }
            
            if !isCancelled {
                try drone.land()
            }
           
        } catch {
            self.error = error
            
            if !isCancelled {
                cancel()
            }
        }
    }
    
    override public func cancel() {
    }
    
}
