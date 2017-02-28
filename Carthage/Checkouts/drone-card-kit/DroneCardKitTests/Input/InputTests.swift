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

class InputTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCardinalDirectionAzimuth() {
        let directionRangeDegrees: Double = 360 / 32.0
        
        for angleDegrees in stride(from: 0, to: 720, by: 7.12345) {
            let angle = DCKAngle(degrees: Double(angleDegrees))
            let direction: DCKCardinalDirection = DCKCardinalDirection.byAngle(angle)
            
            print("testing angle \(angle.degrees) degrees, \(direction) [\(direction.min), \(direction.max))")
            
            assert((angle - direction.min).normalized().degrees <= directionRangeDegrees,
                   "direction minimum angle \(direction.max.degrees) too far from compass angle \(angle.degrees) degrees")
            assert((direction.max - angle).normalized().degrees <= directionRangeDegrees,
                   "direction maximum angle \(direction.max.degrees) too far from compass angle \(angle.degrees) degrees")
        }
    }
}
