//
//  DroneToken.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 9/23/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

import CardKit
import CardKitRuntime

/// Current drone state, read-only. Carries current location, altitude, attitude, and motor state.
public protocol DroneTelemetryToken {
    // MARK: Location & attitude
    var currentLocation: DCKCoordinate2D? { get }
    var currentAltitude: DCKRelativeAltitude? { get }
    
    /// If the values of the pitch, roll, and yaw are 0, the aircraft will be hovering level with a True North heading.
    /// Values range from 0 to 360. 0º represents North, 90º:East, 180º:South, 270º:West, 360º:North
    var currentAttitude: DCKAttitude? { get }
    
    // MARK: Motor state
    var areMotorsOn: Bool? { get }
}

public protocol DroneToken: DroneTelemetryToken {
    func spinMotors(on: Bool) throws
    
    // MARK: Take off
    
    /// Takes off to a default altitude or custom altitude (if specified).
    /// If the drone is already in the air, this function should not do anything.
    ///
    /// - Parameters:
    ///   - altitude: the altitude the drone will climb to. if nil, the drone will take off to it's default take off altitude.
    ///   - completionHandler: AsyncExecutionCompletionHandler
    func takeOff(at altitude: DCKRelativeAltitude?) throws
    
    // MARK: Hover
    
    /// Cancels all current operations and hovers. The drone will fly to an altitude (if specified) and change its yaw (if specified).
    ///
    /// - Parameters:
    ///   - altitude: the height the drone should be at. if nil, the altitude will not change.
    ///   - yaw: the angle the drone should be facing. if nil, the yaw will not change.
    ///   - completionHandler: AsyncExecutionCompletionHandler
    func hover(at altitude: DCKRelativeAltitude?, withYaw yaw: DCKAngle?) throws
    
    // MARK: Fly
    
    /// Fly to a coordinate at an altitude, speed, and yaw. The drone will change its yaw angle and then fly to the location.
    /// The yaw angle will be updated by calling the hover(withYaw:) function.
    ///
    /// - Parameters:
    ///   - coordinate: the location the drone needs to fly to
    ///   - yaw: the angle the drone should be facing. if nil, the yaw will not change.
    ///   - altitude: the height the drone should be at. if nil, the altitude will not change.
    ///   - speed: the speed the drone should be flying. if nil, the default speed will be used (8 m/s)
    ///   - completionHandler: AsyncExecutionCompletionHandler
    func fly(to coordinate: DCKCoordinate2D, atYaw yaw: DCKAngle?, atAltitude altitude: DCKRelativeAltitude?, atSpeed speed: DCKSpeed?) throws
    func fly(on path: DCKCoordinate2DPath, atAltitude altitude: DCKRelativeAltitude?, atSpeed speed: DCKSpeed?) throws
    func fly(on path: DCKCoordinate3DPath, atSpeed speed: DCKSpeed?) throws
    
    // MARK: Circle
    func circle(around center: DCKCoordinate2D, atRadius radius: DCKDistance, atAltitude altitude: DCKRelativeAltitude, atAngularSpeed angularSpeed: DCKAngularVelocity?, atClockwise isClockwise: DCKMovementDirection?, toCircleRepeatedly toRepeat: Bool) throws
    
    // MARK: Return home
    var homeLocation: DCKCoordinate2D? { get }
    func returnHome(atAltitude altitude: DCKRelativeAltitude?, atSpeed speed: DCKSpeed?, toLand land: Bool) throws
    
    // MARK: Spin Around
    func spinAround(toYawAngle yaw: DCKAngle, atAngularSpeed angularSpeed: DCKAngularVelocity?) throws
    // MARK: Landing gear
    var isLandingGearDown: Bool? { get }
    func landingGear(down: Bool) throws
    
    // MARK: Land
    
    /// Lands the drone at the current location. Once the drone has landed, the motors will automatically turn off.
    ///
    /// - Parameter completionHandler: AsyncExecutionCompletionHandler
    func land() throws
}


// MARK: - Convienience Functions for Default Parameters

public extension DroneToken {
    
    // takeOff without altitude specified
    final func takeOff(at altitude: DCKRelativeAltitude? = nil) throws {
        try self.takeOff(at: nil)
    }
    
    // hover without Yaw angle specified
    final func hover(at altitude: DCKRelativeAltitude? = nil, withYaw yaw: DCKAngle? = nil) throws {
        try self.hover(at: altitude, withYaw: nil)
    }
    
    //fly to with DCKCoordinate2D
    final func fly(to coordinate: DCKCoordinate2D, atYaw yaw: DCKAngle? = nil, atAltitude altitude: DCKRelativeAltitude? = nil, atSpeed speed: DCKSpeed? = nil) throws {
        try self.fly(to: coordinate, atYaw: yaw, atAltitude: altitude, atSpeed: speed)
    }
    
    //fly to with DCKOrientedCoordinate2D
    final func fly(to coordinate: DCKOrientedCoordinate2D, atAltitude altitude: DCKRelativeAltitude? = nil, atSpeed speed: DCKSpeed? = nil) throws {
        try self.fly(to: coordinate.asNonOriented(), atYaw: coordinate.yaw, atAltitude: altitude, atSpeed: speed)
    }
    
    //fly to with DCKCoordinate3D
    final func fly(to coordinate: DCKCoordinate3D, atYaw yaw: DCKAngle? = nil, atSpeed speed: DCKSpeed? = nil) throws {
        try self.fly(to: coordinate.as2D(), atYaw: yaw, atAltitude: coordinate.altitude, atSpeed: speed)
    }
    
    final func fly(on path: DCKCoordinate2DPath, atAltitude altitude: DCKRelativeAltitude? = nil, atSpeed speed: DCKSpeed? = nil) throws {
        try self.fly(on: path, atAltitude: altitude, atSpeed: speed)
    }
}

// MARK: - DroneTokenError

public enum DroneTokenError: Error {
    case failureInFlightTriggersLand
    case failureDuringLand
    case failureDuringHover
    case failureRetrievingDroneState
}
