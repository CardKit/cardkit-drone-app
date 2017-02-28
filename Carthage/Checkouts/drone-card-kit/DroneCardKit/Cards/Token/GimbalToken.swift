//
//  GimbalToken.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 11/29/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

import CardKit
import CardKitRuntime

public protocol GimbalToken {
    var currentAttitude: DCKAttitude? { get }
    
    func calibrate() throws
    func reset() throws
    
    /// Rotates the gimbal to a yaw, pitch, and roll in the specified amount of time. 0º always points towards the front of the drone. Values can range from 0 to 360. Value being negative indicates a reverse movement.
    /// Picture this unit circle: https://i.stack.imgur.com/FR229.png perpendicular to the axis of yaw, pitch, or roll. The gimbal will rotate the number of degrees specified in the direction of the unit circle. See below for examples.
    ///
    /// - Parameters:
    ///   - yaw: Rotation along the perpendicular axis. Example: 90º rotation for yaw will rotate the gimbal right by 90º
    ///   - pitch: Rotation along the lateral axis. Example: 90º rotation for pitch will rotate the gimbal down by 90º
    ///   - roll: Rotation along the longitudinal axis. Example: 90º rotation for roll will rotate the gimbal clockwise by 90º
    ///   - relativeToDrone: if true, rotation will be performed relative to current gimbal position. if false, this will be considered as an absolute position.
    ///   - withinTimeInSeconds: the amount of time in which the drone should perform the rotation.
    func rotate(yaw: DCKAngle?, pitch: DCKAngle?, roll: DCKAngle?, relativeToDrone: Bool, withinTimeInSeconds duration: Double?) throws
    
    func rotate(yaw: DCKAngularVelocity?, pitch: DCKAngularVelocity?, roll: DCKAngularVelocity?, forTimeInSeconds duration: Double) throws
    
    /// Rotate the gimbal to a given position.
    func orient(to position: GimbalOrientation) throws
}

// MARK: - GimbalOrientation

public enum GimbalOrientation {
    case facingForward
    case facingDownward
}

// MARK: - Convienience Functions for Default Parameters

public extension GimbalToken {
    func rotate(yaw: DCKAngle? = nil, pitch: DCKAngle? = nil, roll: DCKAngle? = nil, relativeToDrone: Bool = false, withinTimeInSeconds: Double? = nil) throws {
        try self.rotate(yaw: yaw, pitch: pitch, roll: roll, relativeToDrone: relativeToDrone, withinTimeInSeconds: withinTimeInSeconds)
    }
    
    func rotate(yaw: DCKAngularVelocity? = nil, pitch: DCKAngularVelocity? = nil, roll: DCKAngularVelocity? = nil, forTimeInSeconds seconds: Double) throws {
        try self.rotate(yaw: yaw, pitch: pitch, roll: roll, forTimeInSeconds: seconds)
    }
}

public enum GimbalTokenError: Error {
    case failedToBeginCalibration
}
