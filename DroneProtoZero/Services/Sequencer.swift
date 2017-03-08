//
//  Sequencer.swift
//  DroneProtoZero
//
//  Created by boland on 3/8/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import CardKit

class Sequencer {
    
    static let shared: Sequencer = Sequencer()
    
    var hands: [Hand]
    
    init() {
        hands = [Hand]()
        let _ = createHand()
    }
    
    func createHand() -> Hand {
        let hand = Hand()
        hands.append(hand)
        return hand
    }
    
    func addHand() -> HandIdentifier {
        let hand = createHand()
        return hand.identifier
    }
    
    func removeHand(sectionID: Int) -> HandIdentifier? {
        guard let hand = getHand(by: sectionID) else { return nil }
        removeHand(identifier: hand.identifier)
        return hand.identifier
    }
    
    func removeHand(identifier: CardIdentifier) {
        if let hand = getHand(by: identifier), let index = hands.index(of: hand) {
            hands.remove(at: index)
        }
    }
    
    func getHand(by identifier: HandIdentifier) -> Hand? {
        let filteredHands = hands.filter { $0.identifier == identifier }
        guard filteredHands.count > 0 else { return nil }
        return filteredHands.first
    }
    
    func getHand(by index: Int) -> Hand? {
        let actualID =  index - defaultSectionCount
        guard hands.indices.contains(actualID) else { return nil }
        return hands[actualID]
    }
    
    // MARK: Card Adding/Removing Methods
    
    func addCard(card: ActionCardDescriptor, toHand index: Int) throws {
        guard let hand = getHand(by: index) else { return }
        let cardInstance = try card <- []
        let _ = hand ++ cardInstance
    }
    
    func removeCard(cardID: CardIdentifier, fromHand index: Int) {
        guard let hand = getHand(by: index) else { return }
        let filtered = hand.cards.filter { $0.identifier == cardID }
        
        guard let card = filtered.first as? ActionCard else { return }
        hand.remove(card)
    }

}
