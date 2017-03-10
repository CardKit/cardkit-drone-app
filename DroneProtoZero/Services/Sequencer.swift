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
    
    func removeHand(by index: Int) -> HandIdentifier? {
        guard let hand = getHand(by: index) else { return nil }
        removeHand(by: hand.identifier)
        return hand.identifier
    }
    
    func removeHand(by identifier: CardIdentifier) {
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
        guard hands.indices.contains(index) else { return nil }
        return hands[index]
    }
    
    func getCard(forHand handIndex: Int, cardIndex: Int) -> Card? {
        guard let hand = getHand(by: handIndex) else { return nil }
        let cards = hand.cards
        guard cards.indices.contains(cardIndex) else { return nil }
        return cards[cardIndex]
    }
    
    // MARK: Card Adding/Removing Methods
    
    /**
    - Add Card :
     - adds the card to hand associated with the Step (section)
     - cardDescriptor: CardDescriptor
     - index: Int - index of the hand 
    */
    func addCard(card: ActionCardDescriptor, toHand index: Int) throws {
        guard let hand = getHand(by: index) else { return }
        let cardInstance = try card <- []
        let _ = hand ++ cardInstance
    }
    
    /**
     - Remove Card
        - removes the card using the identifier from the given hand
        * cardID: CardIdentifier (String)
        * index: index of the Hand in the hands array
    */
    func removeCard(cardID: CardIdentifier, fromHand index: Int) {
        guard let hand = getHand(by: index) else { return }
        let filtered = hand.cards.filter { $0.identifier == cardID }
        
        guard let card = filtered.first as? ActionCard else { return }
        hand.remove(card)
    }

}
