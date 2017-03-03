//
//  CanvasViewModel.swift
//  DroneProtoZero
//
//  Created by boland on 2/28/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import CardKit
import Freddy

enum CanvasSection: Int {
    case status
    case hardware
    case steps
}

struct CanvasViewModel {
    
    var sectionCount = 3
    var hands: [Hand]
    
    init() {
        hands = [Hand]()
        createHand()
    }
    
    func cellHeight(for indexPath: IndexPath) -> Float {
        guard let section = sectionType(for: indexPath.section) else { return 0 }
        switch section {
        case .status:
            return 55.0
        case .hardware:
            return 70.0
        default:
            return 228.0
        }
    }
    
    func headerHeight(section: Int) -> Float {
        guard let section = sectionType(for: section) else { return 1.0 }
        switch section {
        case .status:
            return 20.0
        case .hardware:
            return 1.0
        case .steps:
            return 50.0
        }
    }
    
    func sectionType(for section: Int) -> CanvasSection? {
        guard let section = CanvasSection(rawValue: section) else { return CanvasSection.steps }
        return section
    }
    
    func createIndexSet(section: Int) -> IndexSet {
        let startIndex = section + 1
        let endIndex = sectionCount
        let otherSections = startIndex...endIndex
        let arrayOfSections = Array(otherSections)
        return IndexSet(arrayOfSections)
    }
    
    mutating func createHand() {
      
//        do {
//            let hand = try Hand()
//            hands.append(hand)
//        } catch {
//            fatalError("Could not make a hand so we should just stop right here")
//        }
    }
    
    func getHand(by identifier: HandIdentifier) -> Hand? {
        let filteredHands = hands.filter { $0.identifier == identifier }
        guard filteredHands.count > 0 else { return nil }
        return filteredHands[0]
    }
    
}
