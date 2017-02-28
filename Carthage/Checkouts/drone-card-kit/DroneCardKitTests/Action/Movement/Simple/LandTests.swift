//
//  LandTests.swift
//  DroneCardKit
//
//  Created by ismails on 12/9/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import XCTest

@testable import CardKit    
@testable import CardKitRuntime
@testable import DroneCardKit

class LandTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLand() {
        // land card
        let land = Land(with: DroneCardKit.Action.Movement.Simple.Land.makeCard())
        
        guard let droneTokenSlot = land.actionCard.tokenSlots.slot(named: "Drone") else {
            XCTFail("expected Land card to have slot named Drone")
            return
        }
        
        // drone token card
        let droneCard = DroneCardKit.Token.Drone.makeCard()
        
        // drone token instance
        let dummyDrone = DummyDroneToken(with: droneCard)
        
        // bind
        land.setup([:], tokens: [droneTokenSlot: dummyDrone])
        
        // execute
        land.main()
        
        XCTAssertTrue(dummyDrone.calledFunctions.contains("land"), "land should have been called")
        XCTAssertTrue(dummyDrone.calledFunctions.count == 1, "only one card should have been called")
    }
}
