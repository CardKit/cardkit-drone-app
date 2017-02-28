//
//  DummyCameraToken.swift
//  DroneCardKit
//
//  Created by Justin Weisz on 1/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

import CardKit
import CardKitRuntime

public class DummyCameraToken: ExecutableTokenCard, CameraToken {
    let prefix = ">> "
    let delay: TimeInterval = 3.0
    
    var isTakingPhotos = false
    var isTakingTimelapse = false
    var isTakingVideo = false
    
    public func takePhoto(options: Set<CameraPhotoOption>) throws {
        print("\(prefix) DummyCameraToken > takePhoto(options: \(options))")
        Thread.sleep(forTimeInterval: delay)
    }
    
    public func takeHDRPhoto(options: Set<CameraPhotoOption>) throws {
        print("\(prefix) DummyCameraToken > takeHDRPhoto(options: \(options))")
        Thread.sleep(forTimeInterval: delay)
    }
    
    public func takePhotoBurst(count: PhotoBurstCount, options: Set<CameraPhotoOption>) throws {
        print("\(prefix) DummyCameraToken > takePhotoBurst(count: \(count), options: \(options))")
        Thread.sleep(forTimeInterval: delay)
    }
    
    public func startTakingPhotos(at interval: TimeInterval, options: Set<CameraPhotoOption>) throws {
        print("\(prefix) DummyCameraToken > startTakingPhotos(at: \(interval), options: \(options))")
        
        if self.isTakingPhotos || self.isTakingTimelapse || self.isTakingVideo {
            throw CameraTokenError.cameraAlreadyInUse
            return
        }
        
        self.isTakingPhotos = true
    }
    
    public func stopTakingPhotos() throws {
        print("\(prefix) DummyCameraToken > stopTakingPhotos()")
        self.isTakingPhotos = false
    }
    
    /// Start taking a timelapse movie.
    public func startTimelapse(options: Set<CameraPhotoOption>) throws {
        print("\(prefix) DummyCameraToken > startTimelapse(options: \(options))")
        
        if self.isTakingPhotos || self.isTakingTimelapse || self.isTakingVideo {
            throw CameraTokenError.cameraAlreadyInUse
        }
        
        self.isTakingTimelapse = true
    }
    
    /// Stop taking a timelapse movie.
    public func stopTimelapse() throws {
        print("\(prefix) DummyCameraToken > stopTimelapse()")
        self.isTakingTimelapse = false
    }
    
    public func startVideo(options: Set<CameraVideoOption>) throws {
        print("\(prefix) DummyCameraToken > startVideo(options: \(options))")
        
        if self.isTakingPhotos || self.isTakingTimelapse || self.isTakingVideo {
            throw CameraTokenError.cameraAlreadyInUse
        }
        
        self.isTakingVideo = true
    }
    
    public func stopVideo() throws {
        print("\(prefix) DummyCameraToken > stopVideo()")
        self.isTakingVideo = false
    }
}
