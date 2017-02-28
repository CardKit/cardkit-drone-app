//
//  PointAtLocation.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 1/30/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class PointAtLocation: ExecutableActionCard {
    override public func main() {
        guard let droneTelemetry: DroneTelemetryToken = self.token(named: "DroneTelemetry") as? DroneTelemetryToken,
            let gimbal: GimbalToken = self.token(named: "Gimbal") as? GimbalToken,
            let desiredLocation: DCKCoordinate3D = self.value(forInput: "Location") else {
                return
        }
        
        guard let currentLocation = droneTelemetry.currentLocation,
            let currentAltitude = droneTelemetry.currentAltitude,
            let currentAttitude = droneTelemetry.currentAttitude else {
            self.error = DroneTokenError.failureRetrievingDroneState
            return
        }
        
        // make an oriented 3D coordinate for the drone's location
        let droneLocation = DCKOrientedCoordinate3D(latitude: currentLocation.latitude, longitude: currentLocation.longitude, altitude: currentAltitude, yaw: currentAttitude.yaw)
        
        // calculate the bearing between the drone and the desiredLocation
        let yaw = droneLocation.bearing(to: desiredLocation)
        
        // calculate the pitch angle needed to orient the gimbal to the desiredLocation
        let pitch = droneLocation.asNonOriented().pitch(to: desiredLocation)
        
        do {
            if !isCancelled {
                try gimbal.rotate(yaw: yaw, pitch: pitch, relativeToDrone: false)
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
