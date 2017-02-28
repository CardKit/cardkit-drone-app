//
//  PanBetweenLocations.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 1/30/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class PanBetweenLocations: ExecutableActionCard {
    override public func main() {
        guard let droneTelemetry: DroneTelemetryToken = self.token(named: "DroneTelemetry") as? DroneTelemetryToken,
            let gimbal: GimbalToken = self.token(named: "Gimbal") as? GimbalToken,
            let startLocation: DCKCoordinate3D = self.value(forInput: "StartLocation"),
            let endLocation: DCKCoordinate3D = self.value(forInput: "EndLocation") else {
            return
        }
        
        let duration: Double? = self.optionalValue(forInput: "Duration")
        
        // rotate to the start location
        var coordinate: DCKCoordinate3D = startLocation
        
        // pan between locations until we are finished executing
        while !self.isCancelled {
            // get the current location of the drone
            guard let currentLocation = droneTelemetry.currentLocation,
                let currentAltitude = droneTelemetry.currentAltitude,
                let currentAttitude = droneTelemetry.currentAttitude else {
                    self.error = DroneTokenError.failureRetrievingDroneState
                    return
            }
            
            // make an oriented 3D coordinate for the drone's location
            let droneLocation = DCKOrientedCoordinate3D(latitude: currentLocation.latitude, longitude: currentLocation.longitude, altitude: currentAltitude, yaw: currentAttitude.yaw)
            
            // calculate the bearing between the drone and the coordinate
            let yaw = droneLocation.bearing(to: coordinate)
            
            // calculate the pitch angle needed to orient the gimbal to the coordinate
            let pitch = droneLocation.asNonOriented().pitch(to: coordinate)
            
            // rotate the gimbal
            do {
                if !self.isCancelled {
                    if let duration = duration {
                        try gimbal.rotate(yaw: yaw, pitch: pitch, relativeToDrone: false, withinTimeInSeconds: duration)
                    } else {
                        try gimbal.rotate(yaw: yaw, pitch: pitch, relativeToDrone: false)
                    }
                }
            } catch {
                self.error = error
                
                if !self.isCancelled {
                    self.cancel()
                }
            }
            
            // set up for the other coordinate
            coordinate = (coordinate == startLocation) ? endLocation : startLocation
        }
    }
    
    override public func cancel() {
        // panning will stop automatically when cancel() is called
    }
    
    func pitchAndYaw(from startCoordinate: DCKCoordinate3D, to endCoordinate: DCKCoordinate3D, relativeToYaw yaw: DCKAngle) -> (DCKAngle, DCKAngle) {
        // calculate the absolute bearing between the two coordinates
        let bearing = startCoordinate.bearing(to: endCoordinate)
        
        // calculate the relative bearing between the drone's yaw and the absolute bearing
        let relativeBearing = bearing - yaw
        
        // normalize the bearing (so negative angles become positive)
        let normalizedRelativeBearing = relativeBearing.normalized()
        
        // calculate the pitch angle needed to orient the gimbal to the desiredLocation
        let pitch = startCoordinate.pitch(to: endCoordinate)
        
        return (normalizedRelativeBearing, pitch)
    }
}
