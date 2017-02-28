//
//  TakeTimelapse.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 1/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

import CardKitRuntime

public class TakeTimelapse: ExecutableActionCard {
    override public func main() {
        guard let camera: CameraToken = self.token(named: "Camera") as? CameraToken else {
            return
        }
        
        let aspect: PhotoAspectRatio? = self.optionalValue(forInput: "AspectRatio")
        let quality: PhotoQuality? = self.optionalValue(forInput: "Quality")
        
        var cameraOptions: Set<CameraPhotoOption> = []
        if let aspect = aspect {
            cameraOptions.insert(.aspectRatio(aspect))
        }
        if let quality = quality {
            cameraOptions.insert(.quality(quality))
        }
        
        do {
            if !isCancelled {
                try camera.startTimelapse(options: cameraOptions)
            }
        } catch {
            self.error = error
            
            if !isCancelled {
                cancel()
            }
        }
    }
    
    override public func cancel() {
        guard let camera: CameraToken = self.token(named: "Camera") as? CameraToken else {
            return
        }
        
        do {
            try camera.stopTimelapse()
        } catch let error {
            self.error = error
        }
    }
}
