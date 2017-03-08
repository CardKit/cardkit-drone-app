//
//  CanvasViewModel.swift
//  DroneProtoZero
//
//  Created by boland on 2/28/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import CardKit

enum CanvasSection: Int {
    case status
    case hardware
    case steps
}

struct CanvasViewModel {

    let defaultSectionCount: Int = 2
    
    var sectionCount: Int {
        return Sequencer.shared.hands.count + defaultSectionCount
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
    
    // MARK: Hand Creating/Removing Methods
    
    func createHand() -> Hand {
        return Sequencer.shared.createHand()
    }
    
    func addHand() -> HandIdentifier {
        return Sequencer.shared.addHand()
    }
    
    mutating func removeHand(sectionID: Int) -> HandIdentifier? {
        return Sequencer.shared.removeHand(by: sectionID)
    }
    
    mutating func removeHand(identifier: CardIdentifier) {
       Sequencer.shared.removeHand(by: identifier)
    }
    
    func getHand(by index: Int) -> Hand? {
        let actualID =  index - defaultSectionCount
        return Sequencer.shared.getHand(by: actualID)
    }
    
    // MARK: Card Adding/Removing Methods
    
    func addCard(cardDescriptor: ActionCardDescriptor, toHand index: Int) throws {
        let actualID = index - defaultSectionCount
        try Sequencer.shared.addCard(card: cardDescriptor, toHand: actualID)
    }
    
    func removeCard(cardID: CardIdentifier, fromHand index: Int) {
        guard let hand = getHand(by: index) else { return }
        let filtered = hand.cards.filter { $0.identifier == cardID }
        
        guard let card = filtered.first as? ActionCard else { return }
        hand.remove(card)
    }
    
    
    
}
