//
//  InputTests.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 1/19/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest

@testable import CardKit
@testable import CardKitRuntime
@testable import DroneCardKit

class DCKCoordinate2DTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDistanceTo() {
        // verified using http://www.movable-type.co.uk/scripts/latlong.html
        // http://www.onlineconversion.com/map_greatcircle_distance.htm
        // http://andrew.hedges.name/experiments/haversine/ < this calc is off by a few decimal points
        let coordinate1 = DCKCoordinate2D(latitude: 50.066, longitude: -5.714)
        let coordinate2 = DCKCoordinate2D(latitude: 58.643, longitude: -3.070)
        
        let distanceBetween = coordinate1.distance(to: coordinate2)
        let expectedValue: Double = 968791.14
        XCTAssert(abs(distanceBetween - expectedValue) < 0.01, "incorrect distance. calculated value: \(distanceBetween)")
    }
    
    func testBearing() {
        // verified using: http://www.igismap.com/formula-to-find-bearing-or-heading-angle-between-two-points-latitude-longitude/
        let coordinate1 = DCKCoordinate2D(latitude: 39.099912, longitude: -94.581213)
        let coordinate2 = DCKCoordinate2D(latitude: 38.627089, longitude: -90.200203)
        
        let bearingTo = coordinate1.bearing(to: coordinate2).degrees
        let expectedBearingValue: Double = 96.51
        
        XCTAssert(abs(bearingTo - expectedBearingValue) < 0.01, "incorrect bearing. calculated value: \(bearingTo)")
        
        var currentDroneAttitude = DCKAttitude(yaw: DCKAngle(degrees: 50), pitch: DCKAngle(degrees: 0), roll: DCKAngle(degrees: 0))
        var relativeBearing = bearingTo - currentDroneAttitude.yaw.degrees
        var yawAngleNormalized = DCKAngle(degrees: relativeBearing).normalized()
        var expectedYawAngle: Double = 46.51
        var yawAngleNormErr = yawAngleNormalized.degrees - expectedYawAngle
        
        XCTAssert(abs(yawAngleNormalized.degrees - expectedYawAngle) < 0.01, "incorrect yaw angle for gimbal. calculated value: \(yawAngleNormalized)")
        
        currentDroneAttitude = DCKAttitude(yaw: DCKAngle(degrees: 180), pitch: DCKAngle(degrees: 0), roll: DCKAngle(degrees: 0))
        relativeBearing = bearingTo - currentDroneAttitude.yaw.degrees
        yawAngleNormalized = DCKAngle(degrees: relativeBearing).normalized()
        expectedYawAngle = 276.51 //-83.49
        yawAngleNormErr = yawAngleNormalized.degrees - expectedYawAngle
        
        XCTAssert(-0.01 < yawAngleNormErr && yawAngleNormErr < 0.01, "incorrect yaw angle for gimbal. calculated value: \(yawAngleNormalized)")
    }
}
