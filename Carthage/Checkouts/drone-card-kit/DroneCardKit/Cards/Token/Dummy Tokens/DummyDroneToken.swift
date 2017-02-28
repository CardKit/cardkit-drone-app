//
//  DummyDroneToken.swift
//  DroneCardKit
//
//  Created by ismails on 12/9/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

import CardKit
import CardKitRuntime

public class DummyDroneToken: ExecutableTokenCard, DroneToken {
    let prefix = ">> "
    let delay: TimeInterval = 3.0
    
    public var homeLocation: DCKCoordinate2D?
    
    public var currentLocation: DCKCoordinate2D?
    public var currentAltitude: DCKRelativeAltitude?
    public var currentAttitude: DCKAttitude?
    
    public var areMotorsOn: Bool?
    public var isLandingGearDown: Bool?
    
    var calledFunctions: [String] = []
    
    override public init(with card: TokenCard) {
        self.homeLocation = DCKCoordinate2D(latitude: 0, longitude: 0)
        self.currentLocation = DCKCoordinate2D(latitude: 0, longitude: 0)
        self.currentAltitude = DCKRelativeAltitude(metersAboveGroundAtTakeoff: 0)
        self.currentAttitude = DCKAttitude(yaw: DCKAngle(degrees: 0), pitch: DCKAngle(degrees: 0), roll: DCKAngle(degrees: 0))
        self.areMotorsOn = false
        self.isLandingGearDown = true
        
        super.init(with: card)
    }
    
    // MARK: Instance Methods
    private func registerFunctionCall(named name: String) {
        self.calledFunctions.append(name)
    }
    
    // MARK: DroneToken
    public func spinMotors(on: Bool) throws {
        self.registerFunctionCall(named: "spinMotors")
        print("\(prefix) DummyDroneToken > turnMotorsOn()")
        Thread.sleep(forTimeInterval: delay)
        
        areMotorsOn = on
    }
    
    public func takeOff(at altitude: DCKRelativeAltitude?) throws {
        self.registerFunctionCall(named: "takeOff")
        print("\(prefix) DummyDroneToken > takeOff(at: \(altitude))")
        Thread.sleep(forTimeInterval: delay)
        
        try spinMotors(on: true)
        try landingGear(down: false)
        
        var newAltitude = DCKRelativeAltitude(metersAboveGroundAtTakeoff: 1)
        
        if let specifiedAltitude = altitude {
            newAltitude = specifiedAltitude
        }
        
        self.currentAltitude = newAltitude
    }
    
    public func hover(at altitude: DCKRelativeAltitude?, withYaw yaw: DCKAngle?) throws {
        self.registerFunctionCall(named: "hover")
        print("\(prefix) DummyDroneToken > hover(at: \(altitude), withYaw: \(yaw))")
        Thread.sleep(forTimeInterval: delay)
        
        if let specifiedAltitude = altitude {
            self.currentAltitude = specifiedAltitude
        }
    }
    
    public func fly(to coordinate: DCKCoordinate2D, atYaw yaw: DCKAngle?, atAltitude altitude: DCKRelativeAltitude?, atSpeed speed: DCKSpeed?) throws {
        self.registerFunctionCall(named: "fly:to:atYaw:atAltitude:atSpeed:completionHandler")
        print("\(prefix) DummyDroneToken > fly(to: \(coordinate), atYaw: \(yaw), atAltitude: \(altitude), atSpeed: \(speed))")
        Thread.sleep(forTimeInterval: delay)
        
        guard let currentAttitude = self.currentAttitude else {
            throw DroneTokenError.failureRetrievingDroneState
        }
        
        let newYaw: DCKAngle
        
        if let yaw = yaw {
            newYaw = yaw
        } else {
            newYaw = currentAttitude.yaw
        }
        
        let newCoord = DCKCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.currentLocation = newCoord
        
        if let altitude = altitude {
            self.currentAltitude = altitude
        }
        
        let newAttitude = DCKAttitude(yaw: newYaw, pitch: currentAttitude.pitch, roll: currentAttitude.roll)
        self.currentAttitude = newAttitude
    }
    
    public func fly(on path: DCKCoordinate2DPath, atAltitude altitude: DCKRelativeAltitude?, atSpeed speed: DCKSpeed?) throws {
        self.registerFunctionCall(named: "fly:on:atAltitude:atSpeed:completionHandler")
        print("\(prefix) DummyDroneToken > fly(on: \(path), atAltitude: \(altitude), atSpeed: \(speed))")
        Thread.sleep(forTimeInterval: delay)
        
        for coord in path.path {
            try self.fly(to: coord, atAltitude: altitude, atSpeed: speed)
        }
    }
    
    public func fly(on path: DCKCoordinate3DPath, atSpeed speed: DCKSpeed?) throws {
        self.registerFunctionCall(named: "fly:on:atSpeed:completionHandler")
        print("\(prefix) DummyDroneToken > fly(on: \(path), atSpeed: \(speed))")
        Thread.sleep(forTimeInterval: delay)
        
        for coord in path.path {
            try self.fly(to: coord.as2D(), atAltitude: coord.altitude, atSpeed: speed)
        }
    }
    
    public func circle(around center: DCKCoordinate2D, atRadius radius: DCKDistance, atAltitude altitude: DCKRelativeAltitude, atAngularSpeed angularSpeed: DCKAngularVelocity?, atClockwise isClockwise: DCKMovementDirection?, toCircleRepeatedly toRepeat: Bool) throws {
        self.registerFunctionCall(named: "circle:around:atRadius:atAltitude:atAngularSpeed:atClockwise")
        print("\(prefix) DummyDroneToken > circle(around: \(center), atRadius: \(radius), atAltitude: \(altitude), atAngularSpeed: \(angularSpeed), atClockwise: \(isClockwise), toCircleRepeatedly: \(toRepeat)")
        Thread.sleep(forTimeInterval: delay)
    }

    
    public func returnHome(atAltitude altitude: DCKRelativeAltitude?, atSpeed speed: DCKSpeed?, toLand land: Bool) throws {
        self.registerFunctionCall(named: "returnHome")
        print("\(prefix) DummyDroneToken > returnHome(atAltitude: \(altitude), atSpeed: \(speed), toLand: \(land))")
        Thread.sleep(forTimeInterval: delay)
        
        
        guard let homeLocation = self.homeLocation else {
            throw DroneTokenError.failureRetrievingDroneState
        }
        
        try self.fly(to: homeLocation)
        
        if land { try self.land() }
    }
    
    public func spinAround(toYawAngle yaw: DCKAngle, atAngularSpeed angularSpeed: DCKAngularVelocity?) throws {
        self.registerFunctionCall(named: "spinAround")
        print("\(prefix) DummyDroneToken > Spin Around (toYawAngle: \(yaw), atAngularSpeed: \(angularSpeed)")
        Thread.sleep(forTimeInterval: delay)
    }
    
    public func landingGear(down: Bool) throws {
        self.registerFunctionCall(named: "landingGear")
        print("\(prefix) DummyDroneToken > landingGear(down: \(down))")
        Thread.sleep(forTimeInterval: delay)
        
        self.isLandingGearDown = down
    }
    
    public func land() throws {
        self.registerFunctionCall(named: "land")
        print("\(prefix) DummyDroneToken > land()")
        Thread.sleep(forTimeInterval: delay)
        
        let newAltitude = DCKRelativeAltitude(metersAboveGroundAtTakeoff: 0)
        self.currentAltitude = newAltitude
    }
}
