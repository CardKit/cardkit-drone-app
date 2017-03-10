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

// this should be removed once this function gets into CardKit
extension Deck {
    /// Add the Token card to the Deck.
    public func add(_ cards: [TokenCard]) {
        self.tokenCards.append(contentsOf: cards)
    }
}

class Sequencer {
    // this should be removed once this property gets into DroneCardKit
    public struct TokenSlotNames {
        public static let drone = "Drone"
        public static let camera = "Camera"
        public static let gimbal = "Gimbal"
        public static let telemetry = "Telemetry"
    }
    
    // this should be removed once this property gets into DroneCardKit
    public static var executableActionTypes: [ActionCardDescriptor : ExecutableAction.Type] = [
        DroneCardKit.Action.Movement.Location.Circle: Circle.self,
        DroneCardKit.Action.Movement.Location.CircleRepeatedly: CircleRepeatedly.self,
        DroneCardKit.Action.Movement.Location.FlyTo: FlyTo.self,
        DroneCardKit.Action.Movement.Location.ReturnHome: ReturnHome.self,
        DroneCardKit.Action.Movement.Sequence.FlyPath: FlyPath.self,
        DroneCardKit.Action.Movement.Sequence.Pace: Pace.self,
        DroneCardKit.Action.Movement.Simple.FlyForward: FlyForward.self,
        DroneCardKit.Action.Movement.Simple.Hover: Hover.self,
        DroneCardKit.Action.Movement.Simple.Land: Land.self,
        DroneCardKit.Action.Tech.Camera.RecordVideo: RecordVideo.self,
        DroneCardKit.Action.Tech.Camera.TakePhoto: TakePhoto.self,
        DroneCardKit.Action.Tech.Camera.TakePhotoBurst: TakePhotoBurst.self,
        DroneCardKit.Action.Tech.Camera.TakePhotos: TakePhotos.self,
        DroneCardKit.Action.Tech.Gimbal.PanBetweenLocations: PanBetweenLocations.self,
        DroneCardKit.Action.Tech.Gimbal.PointAtFront: PointAtFront.self,
        DroneCardKit.Action.Tech.Gimbal.PointAtGround: PointAtGround.self,
        DroneCardKit.Action.Tech.Gimbal.PointAtLocation: PointAtLocation.self,
        DroneCardKit.Action.Tech.Gimbal.PointInDirection: PointInDirection.self,
        DroneCardKit.Action.Movement.Area.CoverArea: CoverArea.self,
        DroneCardKit.Action.Movement.Orientation.SpinAround: SpinAround.self
    ]
    
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
    
    // MARK: Card Adding/Removing Methods
    
    /**
     - Add Card :
     - adds the card to hand associated with the Step (section)
     - cardDescriptor: CardDescriptor
     - index: Int - index of the hand
     */
    func addCard(card: ActionCardDescriptor, toHand index: Int) throws {
        guard let hand = getHand(by: index) else { return }
        var cardInstance = try card <- [] <- [("Drone", droneTokenCard), ("Camera", cameraTokenCard), ("Gimbal", gimbalTokenCard)]
        
        var tokenBindings: [(String, TokenCard)] = []
        
        for tokenSlot in card.tokenSlots {
            switch tokenSlot.name {
            case Sequencer.TokenSlotNames.drone:
                tokenBindings.append((Sequencer.TokenSlotNames.drone, droneTokenCard))
            case Sequencer.TokenSlotNames.gimbal:
                tokenBindings.append((Sequencer.TokenSlotNames.gimbal, gimbalTokenCard))
            case Sequencer.TokenSlotNames.camera:
                tokenBindings.append((Sequencer.TokenSlotNames.camera, cameraTokenCard))
            case Sequencer.TokenSlotNames.telemetry:
                tokenBindings.append((Sequencer.TokenSlotNames.telemetry, droneTokenCard))
                break
            default:
                break
            }
        }
        
        cardInstance = try cardInstance <- tokenBindings
        
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
        deck.add(tokenCards)
        
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
        engine.setExecutableActionTypes(Sequencer.executableActionTypes)
        
        // create executable tokens and add to execution engine
        let djiHardwareManager: DJIHardwareManager = DJIHardwareManager.sharedInstance         
        guard let djiAircraft = djiHardwareManager.djiAircraft else {
                throw SequencerError.failedToDetectHardwareOnDrone("Could not retrieve DJIAircraft")
        }
        
        guard let djiCamera = djiHardwareManager.djiCamera else {
                throw SequencerError.failedToDetectHardwareOnDrone("Could not retrieve DJICamera")
        }
        
        guard let djiGimbal = djiHardwareManager.djiGimbal else {
                throw SequencerError.failedToDetectHardwareOnDrone("Could not retrieve DJIGimbal")
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
