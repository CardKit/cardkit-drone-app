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
    
    func testAddCardToStep() throws {
        let viewModel = CanvasViewModel()
        let _ = viewModel.addHand()
        let handID = 3
        
        guard let key = DroneCardDescriptors.sharedInstance.keyAtIndex(index: 0) else {
            XCTFail("Could not get key for index")
            return
        }
        
        let loctioncards = DroneCardDescriptors.sharedInstance.all[key]
        
        guard let circleCard = loctioncards?[0] else {
            XCTFail("Could not get circle card")
            return
        }
        
        try viewModel.addCard(cardDescriptor: circleCard, toHand: handID)
        let hand = viewModel.getHand(by: handID)
        XCTAssertEqual(circleCard.cardType, hand?.cards.first?.cardType)
    }
    
    func testGetCardFromStep() {
        let viewModel = CanvasViewModel()
        let _ = viewModel.addHand()
        let handID = 3
        guard let key = DroneCardDescriptors.sharedInstance.keyAtIndex(index: 0) else {
            XCTFail("no keys")
            return
        }
        let allCards = DroneCardDescriptors.sharedInstance.all
        let loctioncards = allCards[key]
        guard let circleCardDescriptor = loctioncards?[0] else {
            XCTFail("NO CIRCLE CARD")
            return
        }
        do {
            try viewModel.addCard(cardDescriptor: circleCardDescriptor, toHand: handID)
        } catch {
            XCTFail("Could not add a card")
        }
        let hand = viewModel.getHand(by: handID)
        guard let cardFoundArray = hand?.cards(matching: circleCardDescriptor), let cardFound = cardFoundArray.first  else {
            XCTFail("NO CARD FOUND")
            return
        }
        XCTAssertTrue(cardFound.cardType == .action)
    }
    
    func testRemoveCardFromStep() {
        let viewModel = CanvasViewModel()
        let _ = viewModel.addHand()
        let handID = 3
        guard let key = DroneCardDescriptors.sharedInstance.keyAtIndex(index: 0) else {
            XCTFail("no keys")
            return
        }
        let allCards = DroneCardDescriptors.sharedInstance.all
        let loctioncards = allCards[key]
        guard let circleCardDescriptor = loctioncards?[0] else {
            XCTFail("NO CIRCLE CARD")
            return
        }
        do {
            try viewModel.addCard(cardDescriptor: circleCardDescriptor, toHand: handID)
        } catch {
            XCTFail("Could not add a card")
        }
        let hand = viewModel.getHand(by: handID)
        let fullCount = hand?.cards.count
        guard let cardFoundArray = hand?.cards(matching: circleCardDescriptor), let cardFound = cardFoundArray.first  else {
            XCTFail("NO CARD FOUND")
            return
        }
        let _ = viewModel.removeCard(cardID: cardFound.identifier, fromHand: handID)
        guard let checkHand = viewModel.getHand(by: handID) else {
            XCTFail("Cound not get the hand after removing a card")
            return
        }
        XCTAssertEqual(fullCount, checkHand.cards.count+1)
        
    }
}
