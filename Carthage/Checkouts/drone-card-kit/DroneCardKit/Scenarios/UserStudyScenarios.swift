import Foundation

import CardKit

public struct UserStudySenarios {
    private init() {}
    
    private static let movementToken    = DummyMovementToken.defaultInstance
    private static let cameraToken      = DummyMovementToken.defaultInstance
    private static let gimbalToken      = DummyMovementToken.defaultInstance
    private static let buttonToken      = DummyMovementToken.defaultInstance
    private static let clawToken        = DummyMovementToken.defaultInstance
    private static let speakerToken     = DummyMovementToken.defaultInstance
    
    public static func mapYourFarm(boundingBox: InputCoordinate3DPath) -> DeckSpec {
        let coverArea = DroneCardDescs.Movement.Area.CoverArea
            <- ["area": boundingBox]
            <- ["drone": movementToken]
        let takePhotos = DroneCardDescs.Tech.Camera.TakePhotos
            <- ["camera": cameraToken]
        
        return coverArea && takePhotos ==> TERMINATE
    }
    
    public static func tourist(location: InputCoordinate2D) -> DeckSpec {
        let flyToLocation = DroneCardDescs.Movement.Location.FlyTo
            <- [ "location": location]
            <- ["drone": movementToken]
        let pointAtLocation = DroneCardDescs.Tech.Gimbal.PointAtLocation
            <- ["gimbal": gimbalToken]
            <- ["location": location]
        let takeAPhoto = DroneCardDescs.Tech.Camera.TakeAPhoto
            <- ["camera": cameraToken]
        
        return flyToLocation && pointAtLocation ==> takeAPhoto ==> TERMINATE
    }
    
    public static func findEscapedConvicts() {
    }
    
    public static func packageDelivery(
            houseA: InputCoordinate2D = InputCoordinate2D(latitude: 0, longitude: 0),
            houseB: InputCoordinate2D = InputCoordinate2D(latitude: 0, longitude: 0),
            audio: String = "testAudio") -> DeckSpec {
        let flyToHouseA = DroneCardDescs.Movement.Location.FlyTo
            <- ["destination": houseA]
            <- ["drone": movementToken]
        let land = DroneCardDescs.Movement.Simple.Land
            <- ["drone": movementToken]
        let waitForButton = DroneCardDescs.Trigger.Tech.WaitForButtonPush
            <- ["button": buttonToken]
        let closeClaw = DroneCardDescs.Tech.Claw.CloseClaw
            <- ["claw": clawToken]
        let flyToHouseB = DroneCardDescs.Movement.Location.FlyTo
            <- ["destination": houseB]
            <- ["drone": movementToken]
        let hover = DroneCardDescs.Movement.Simple.Hover
            <- ["altitude": 1]
            <- ["drone": movementToken]
        let openClaw = DroneCardDescs.Tech.Claw.OpenClaw
            <- ["claw": clawToken]
        let playAudio = DroneCardDescs.Tech.Speaker.PlayAudio
            <- ["audio": audio]
            <- ["speaker": speakerToken]
        let returnHome = DroneCardDescs.Movement.Location.ReturnHome
            <- ["drone": movementToken]

        return flyToHouseA
            ==> land && waitForButton
            ==> closeClaw
            ==> flyToHouseB
            ==> hover
            ==> openClaw
            ==> playAudio
            ==> returnHome
            ==> TERMINATE
    }

    public static func skiingCoverage(topOfHill: InputCoordinate2D, bottomOfHill: InputCoordinate2D, image: String = "testImage") -> DeckSpec {
        let hover = DroneCardDescs.Movement.Simple.Hover
            <- ["altitude": 100]
            <- ["drone": movementToken]
        let detectSkiier = DroneCardDescs.Think.Find.DetectOnGround
            <- ["image": image]
            <- ["camera": cameraToken]
        let followSkiier = DroneCardDescs.Movement.Relative.Follow
            <- ["altitude": 100]
            <- ["drone": movementToken, "camera": cameraToken, "gimbal": gimbalToken]
        let reachedBottomOfHill = DroneCardDescs.Trigger.Movement.WaitUntilLocation
            <- ["location": bottomOfHill]
        let recordVideo = DroneCardDescs.Tech.Camera.RecordVideo
            <- ["camera": cameraToken]
        
        return hover && detectSkiier
            ==> followSkiier && recordVideo && reachedBottomOfHill
            ==> TERMINATE
    }
    
    public static func gasDetection() {
        
    }
    
}
