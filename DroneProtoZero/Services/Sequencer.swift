//
//  Sequencer.swift
//  DroneProtoZero
//
//  Created by boland on 3/8/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import CardKit
import CardKitRuntime
import DroneCardKit
import DroneTokensDJI

public enum SequencerError: Error {
    case failiedToRetrieveHardwareManager(String)
    case failedToDetectHardwareOnDrone(String)
}

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
    
    func generateDeck() -> Deck {
        // create deck
        let deck = ( hands )%
        
        // create tokens to add to deck
        deck.add(DroneCardKit.tokenCards)
        
        return deck
    }
    
    func validate() -> [ValidationError] {
        let errors = ValidationEngine.validate(generateDeck())
        
        print("******* ******* *******")
        print("Validation Engine Finished\n")
        
        for error in errors {
            print("\(error)\n")
        }
        
        print("******* ******* *******")
        return errors
    }
    
    func execute() throws {
        // create deck
        let deck = generateDeck()
        
        // create executable engine and all all executable actions
        let engine = ExecutionEngine(with: deck)
        engine.setExecutableActionTypes(DroneCardKit.executableActionTypes)
        
        // create executable tokens and add to execution engine
        guard let djiHardwareManager: DJIHardwareManager = DJIHardwareManager.sharedInstance as? DJIHardwareManager else {
            throw SequencerError.failiedToRetrieveHardwareManager("Could not retrieve DJIHardwareManager")
        }
        
        guard let djiAircraft = djiHardwareManager.djiAircraft else {
                throw SequencerError.failedToDetectHardwareOnDrone("Could not retrieve DJIAircraft")
        }
        
        guard let djiCamera = djiHardwareManager.djiCamera else {
                throw SequencerError.failedToDetectHardwareOnDrone("Could not retrieve DJICamera")
        }
        
        guard let djiGimbal = djiHardwareManager.djiGimbal else {
                throw SequencerError.failedToDetectHardwareOnDrone("Could not retrieve DJIGimbal")
        }
        
        let droneExecutableToken = DJIDroneToken(with: DroneCardKit.droneTokenCard, for: djiAircraft)
        
        let cameraExecutableToken = DJICameraToken(with: DroneCardKit.cameraTokenCard, for: djiCamera)
        
        let gimbalExecutableToken = DJIGimbalToken(with: DroneCardKit.gimbalTokenCard, for: djiGimbal)
        
        engine.setTokenInstance(droneExecutableToken, for: DroneCardKit.droneTokenCard)
        engine.setTokenInstance(cameraExecutableToken, for: DroneCardKit.cameraTokenCard)
        engine.setTokenInstance(gimbalExecutableToken, for: DroneCardKit.gimbalTokenCard)
        
        // execute program
        DispatchQueue.global(qos: .default).async {
            engine.execute { (yields: [YieldData], error: ExecutionError?) in
                print("******* ******* *******")
                print("Execution Engine Finished")
                
                print("\n******* YIELDS *******")
                print(yields)
                
                print("\n******* ERROR *******")
                print(error ?? "no error")
                
                print("\n******* ******* *******\n")
            }
        }
        
    }
}
