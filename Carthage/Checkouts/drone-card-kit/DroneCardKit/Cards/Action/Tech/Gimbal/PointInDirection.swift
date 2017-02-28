//
//  PointInDirection.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 1/30/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class PointInDirection: ExecutableActionCard {
    override public func main() {
        guard let droneTelemetry: DroneTelemetryToken = self.token(named: "DroneTelemetry") as? DroneTelemetryToken,
            let gimbal: GimbalToken = self.token(named: "Gimbal") as? GimbalToken,
            let desiredGimbalYaw: DCKAngle = self.value(forInput: "CardinalDirection") else {
                return
        }
        
        guard let droneYaw = droneTelemetry.currentAttitude?.yaw else {
            self.error = DroneTokenError.failureRetrievingDroneState
            return
        }
        
        do {
            if !isCancelled {
                try gimbal.rotate(yaw: droneYaw.normalized() - desiredGimbalYaw.normalized(), relativeToDrone: false)
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
