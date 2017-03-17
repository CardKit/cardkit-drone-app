//
//  DroneProtoZeroTests.swift
//  DroneProtoZeroTests
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import XCTest
@testable import DroneProtoZero
import CardKit

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
        let viewModel = CanvasViewModel()
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
        print("Section count \(viewModel.sectionCount)")
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
    
    func testAddCardToStep() {
        let viewModel = CanvasViewModel()
        let _ = viewModel.addHand()
        let handID = 3
        let key = DroneCardDescriptors.sharedInstance.keyAtIndex(index: 0)
        let allCards = DroneCardDescriptors.sharedInstance.all
        let loctioncards = allCards[key!]
        let circleCard = loctioncards?[0]
        try! viewModel.addCard(cardDescriptor: circleCard!, toHand: handID)
        let hand = viewModel.getHand(by: handID)
        XCTAssertEqual(circleCard?.cardType, hand?.cards.first?.cardType)
    }
    
    func testGetCardFromStep() {
        let viewModel = CanvasViewModel()
        let _ = viewModel.addHand()
        let handID = 3
        let key = DroneCardDescriptors.sharedInstance.keyAtIndex(index: 0)
        let allCards = DroneCardDescriptors.sharedInstance.all
        let loctioncards = allCards[key!]
        let circleCard = loctioncards?[0]
        try! viewModel.addCard(cardDescriptor: circleCard!, toHand: handID)
        let hand = viewModel.getHand(by: handID)
        let cardFound = hand?.cards(matching: circleCard!)
        XCTAssertTrue(cardFound!.first!.cardType == .action)
    }
    
    func testRemoveCardFromStep() {
        let viewModel = CanvasViewModel()
        let _ = viewModel.addHand()
        let handID = 3
        let key = DroneCardDescriptors.sharedInstance.keyAtIndex(index: 0)
        let allCards = DroneCardDescriptors.sharedInstance.all
        let loctioncards = allCards[key!]
        let circleCardDescriptor = loctioncards?[0]
        try! viewModel.addCard(cardDescriptor: circleCardDescriptor!, toHand: handID)
        let hand = viewModel.getHand(by: handID)
        let fullCount = hand?.cards.count
        let circleCardFound = hand?.cards(matching: circleCardDescriptor!)
        let _ = viewModel.removeCard(cardID: (circleCardFound?.first!.identifier)!, fromHand: handID)
        let checkHand = viewModel.getHand(by: handID)
        
        XCTAssertEqual(fullCount, (checkHand?.cards.count)!+1)
        
    }
    
}
