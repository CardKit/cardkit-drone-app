//
//  DroneProtoZeroTests.swift
//  DroneProtoZeroTests
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import XCTest
@testable import DroneProtoZero

class DroneProtoZeroTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanvasSections() {
        let viewModel = CanvasViewModel()
       
        let statusSection = CanvasSection.status
        XCTAssertEqual(statusSection, viewModel.sectionType(for: 0))
        let hardwareSection = CanvasSection.hardware
        XCTAssertEqual(hardwareSection, viewModel.sectionType(for: 1))
        let steps = CanvasSection.steps
        XCTAssertEqual(steps, viewModel.sectionType(for: 2))
        XCTAssertEqual(steps, viewModel.sectionType(for: 3))
        
    }
    
    func testAddStepSection() {
        var viewModel = CanvasViewModel()
        let currentCount = viewModel.sectionCount
        let _ = viewModel.addHand()
        XCTAssertEqual(currentCount+1, viewModel.sectionCount)
    }
    
    func testRemoveStepSection() {
        var viewModel = CanvasViewModel()
        var currentCount = viewModel.sectionCount
        //2 hands
        let handID1 = viewModel.addHand()
        let deleteSection = viewModel.sectionCount
        //3 hands
        let handID2 = viewModel.addHand()
        XCTAssertEqual(currentCount+2, viewModel.sectionCount)
        //2 hands
        viewModel.removeHand(identifier: handID1)
        let indexSet: IndexSet = viewModel.createIndexSet(section: currentCount)
        XCTAssertTrue(indexSet.contains(deleteSection))
        //1 hand
        viewModel.removeHand(identifier: handID2)
        XCTAssertEqual(currentCount, viewModel.sectionCount)
        currentCount = viewModel.sectionCount
        //2 hands
        let _ = viewModel.addHand()
        XCTAssertEqual(currentCount+1, viewModel.sectionCount)
        //1 hands
        let _ = viewModel.removeHand(sectionID: currentCount)
        //check that all the hands are removed
        XCTAssertEqual(currentCount, viewModel.sectionCount)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
