/**
 * Copyright 2018 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
    
    let droneTokenCard = DroneCardKit.Token.Drone.makeCard()
    let cameraTokenCard = DroneCardKit.Token.Camera.makeCard()
    let gimbalTokenCard = DroneCardKit.Token.Gimbal.makeCard()
    let telemetryTokenCard = DroneCardKit.Token.Telemetry.makeCard()
    
    let tokenCards: [TokenCard]
    
    var hands: [Hand]
    
    init() {
        tokenCards = [droneTokenCard, cameraTokenCard, gimbalTokenCard, telemetryTokenCard]
        
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
    func addCard(card: ActionCardDescriptor, toHand index: Int) throws -> ActionCard? {
        guard let hand = getHand(by: index) else { return nil }
        var cardInstance = try card <- []
        var tokenBindings: [(String, TokenCard)] = []
        
        for tokenSlot in card.tokenSlots {
            switch tokenSlot.name {
            case DroneCardKit.TokenSlotNames.drone.rawValue:
                tokenBindings.append((DroneCardKit.TokenSlotNames.drone.rawValue, droneTokenCard))
            case DroneCardKit.TokenSlotNames.gimbal.rawValue:
                tokenBindings.append((DroneCardKit.TokenSlotNames.gimbal.rawValue, gimbalTokenCard))
            case DroneCardKit.TokenSlotNames.camera.rawValue:
                tokenBindings.append((DroneCardKit.TokenSlotNames.camera.rawValue, cameraTokenCard))
            case DroneCardKit.TokenSlotNames.telemetry.rawValue:
                tokenBindings.append((DroneCardKit.TokenSlotNames.telemetry.rawValue, telemetryTokenCard))
                break
            default:
                break
            }
        }
        
        cardInstance = try cardInstance <- tokenBindings
        
        let _ = hand ++ cardInstance
        
        return cardInstance
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
        deck.add(tokenCards)
        
        return deck
    }
    
    func validate() -> [ValidationError] {
        let errors = ValidationEngine.validate(generateDeck())
        
        Logger.log("\nValidated program: ")
        
        if errors.count == 0 {
            Logger.log("\tNo Errors")
        } else {
            for error in errors {
                Logger.log("\t\(error)")
            }
        }
        
        return errors
    }
    
    func execute() throws {
        let prefix = "\t"
        Logger.log("\n Setting up program")
        
        // create deck
        let deck = generateDeck()
        
        // create executable engine and all all executable actions
        let engine = ExecutionEngine(with: deck)
        engine.setExecutableActionTypes(DroneCardKit.executableActionTypes)
        
        // create executable tokens and add to execution engine
        let djiHardwareManager: DJIHardwareManager = DJIHardwareManager.sharedInstance
        guard let djiAircraft = djiHardwareManager.djiAircraft else {
            let errorMessage = "\(prefix) Error: Could not find DJIAircraft"
            Logger.log(errorMessage)
            throw SequencerError.failedToDetectHardwareOnDrone(errorMessage)
        }
        
        guard let djiCamera = djiHardwareManager.djiCamera else {
            let errorMessage = "\(prefix) Error: Could not find DJICamera"
            Logger.log(errorMessage)
            throw SequencerError.failedToDetectHardwareOnDrone(errorMessage)
        }
        
        guard let djiGimbal = djiHardwareManager.djiGimbal else {
            let errorMessage = "\(prefix) Error: Could not find DJIGimbal"
            Logger.log(errorMessage)
            throw SequencerError.failedToDetectHardwareOnDrone(errorMessage)
        }
        
        let droneExecutableToken = DJIDroneToken(with: droneTokenCard, for: djiAircraft)
        let cameraExecutableToken = DJICameraToken(with: cameraTokenCard, for: djiCamera)
        let gimbalExecutableToken = DJIGimbalToken(with: gimbalTokenCard, for: djiGimbal)
        
        engine.setTokenInstance(droneExecutableToken, for: droneTokenCard)
        engine.setTokenInstance(droneExecutableToken, for: telemetryTokenCard)
        engine.setTokenInstance(cameraExecutableToken, for: cameraTokenCard)
        engine.setTokenInstance(gimbalExecutableToken, for: gimbalTokenCard)
        
        // execute program
        DispatchQueue.global(qos: .default).async {
            Logger.log("\(prefix) Executing...")
            
            engine.execute { (yields: [YieldData], error: ExecutionError?) in
                Logger.log("\(prefix) Finished Execution")
                Logger.log("\(prefix) YIELDS: \(yields)")
                Logger.log("\(prefix) ERROR: \(error)")
            }
        }
        
    }
}
