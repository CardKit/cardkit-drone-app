//
//  CameraToken.swift
//  DroneCardKit
//
//  Created by Justin Manweiler on 12/2/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

import Freddy

import CardKit
import CardKitRuntime

// MARK: CameraToken

public protocol CameraToken {
    /// Take a single photo, with the given photo options specified.
    func takePhoto(options: Set<CameraPhotoOption>) throws
    
    /// Take an HDR photo
    func takeHDRPhoto(options: Set<CameraPhotoOption>) throws
    
    /// Take a burst of photos, with the given photo options specified.
    func takePhotoBurst(count: PhotoBurstCount, options: Set<CameraPhotoOption>) throws
    
    /// Start taking photos with a given time interval.
    func startTakingPhotos(at interval: TimeInterval, options: Set<CameraPhotoOption>) throws
    
    /// Stop taking photos.
    func stopTakingPhotos() throws
    
    /// Start taking a timelapse movie.
    func startTimelapse(options: Set<CameraPhotoOption>) throws
    
    /// Stop taking a timelapse movie.
    func stopTimelapse() throws
    
    /// Start taking a video.
    func startVideo(options: Set<CameraVideoOption>) throws
    
    /// Stop taking a video.
    func stopVideo() throws
}

// MARK: - Convienience methods with default parameters

public extension CameraToken {
    /// Take a single photo (16x9, Normal quality).
    final func takePhoto(options: Set<CameraPhotoOption> = [.aspectRatio(.aspect_16x9), .quality(.normal)]) throws {
        try self.takePhoto(options: options)
    }
    
    /// Take a burst of photos (16x9, Normal quality).
    final func takePhotoBurst(count: PhotoBurstCount,
                              options: Set<CameraPhotoOption> = [.aspectRatio(.aspect_16x9), .quality(.normal)]) throws {
        try self.takePhotoBurst(count: count, options: options)
    }
    
    final func startTakingPhotos(at interval: TimeInterval, options: Set<CameraPhotoOption> = []) throws {
        try startTakingPhotos(at: interval, options: options)
    }
    
    final func startTimelapse(options: Set<CameraPhotoOption> = []) throws {
        try startTimelapse(options: options)
    }
    
    func startVideo(options: Set<CameraVideoOption> = []) throws {
        try startVideo(options: options)
    }
}

// MARK: - PhotoBurstCount

public enum PhotoBurstCount: Int {
    case burst_3 = 3
    case burst_5 = 5
    case burst_7 = 7
    case burst_10 = 10
    case burst_14 = 14
}

extension PhotoBurstCount: JSONEncodable, JSONDecodable {}

// MARK: - CameraPhotoOption

public enum CameraPhotoOption {
    case none
    case aspectRatio(PhotoAspectRatio)
    case quality(PhotoQuality)
}

extension CameraPhotoOption: Equatable {
    public static func == (lhs: CameraPhotoOption, rhs: CameraPhotoOption) -> Bool {
        switch lhs {
        case .none:
            if case .none = rhs {
                return true
            } else {
                return false
            }
        case .aspectRatio(let lhs_ratio):
            if case .aspectRatio(let rhs_ratio) = rhs {
                return lhs_ratio == rhs_ratio
            } else {
                return false
            }
        case .quality(let lhs_quality):
            if case .quality(let rhs_quality) = rhs {
                return lhs_quality == rhs_quality
            } else {
                return false
            }
        }
    }
}

extension CameraPhotoOption: Hashable {
    public var hashValue: Int {
        switch self {
        case .none:
            return 0x00
        case .aspectRatio(let ratio):
            return 0x0F + ratio.hashValue
        case .quality(let quality):
            return 0xF0 + quality.hashValue
        }
    }
}

extension CameraPhotoOption: JSONEncodable, JSONDecodable {
    public init(json: JSON) throws {
        let type = try json.getString(at: "type")
        
        switch type {
        case "aspectRatio":
            do {
                let value = try json.getString(at: "value")
                if let ratio = PhotoAspectRatio(rawValue: value) {
                    self = .aspectRatio(ratio)
                } else {
                    self = .none
                }
            } catch {
                self = .none
            }
        case "quality":
            do {
                let value = try json.getString(at: "value")
                if let quality = PhotoQuality(rawValue: value) {
                    self = .quality(quality)
                } else {
                    self = .none
                }
            } catch {
                self = .none
            }
        default:
            self = .none
        }
    }
    
    public func toJSON() -> JSON {
        switch self {
        case .none:
            return .dictionary([
                "type": "none"
            ])
        case .aspectRatio(let ratio):
            return .dictionary([
                "type": "aspectRatio",
                "value": ratio.toJSON()
                ])
        case .quality(let quality):
            return .dictionary([
                "type": "quality",
                "value": quality.toJSON()
            ])
        }
    }
}

// MARK: PhotoAspectRatio

public enum PhotoAspectRatio: String {
    case aspect_4x3
    case aspect_16x9
    case aspect_3x2
}

extension PhotoAspectRatio: JSONEncodable, JSONDecodable {}

// MARK: PhotoQuality

public enum PhotoQuality: String {
    case normal
    case fine
    case excellent
}

extension PhotoQuality: JSONEncodable, JSONDecodable {}

// MARK: - CameraVideoOption

public enum CameraVideoOption {
    case none
    case slowMotionEnabled
    case framerate(VideoFramerate)
    case resolution(VideoResolution)
}

extension CameraVideoOption: Equatable {
    public static func == (lhs: CameraVideoOption, rhs: CameraVideoOption) -> Bool {
        switch lhs {
        case .none:
            if case .none = rhs {
                return true
            } else {
                return false
            }
        case .slowMotionEnabled:
            if case .slowMotionEnabled = rhs {
                return true
            } else {
                return false
            }
        case .framerate(let lhs_fps):
            if case .framerate(let rhs_fps) = rhs {
                return lhs_fps == rhs_fps
            } else {
                return false
            }
        case .resolution(let lhs_resolution):
            if case .resolution(let rhs_resolution) = rhs {
                return lhs_resolution == rhs_resolution
            } else {
                return false
            }
        }
    }
}

extension CameraVideoOption: Hashable {
    public var hashValue: Int {
        switch self {
        case .none:
            return 0x000
        case .slowMotionEnabled:
            return 0x00F
        case .framerate(let fps):
            return 0x0F0 + fps.hashValue
        case .resolution(let resolution):
            return 0xF00 + resolution.hashValue
        }
    }
}

extension CameraVideoOption: JSONEncodable, JSONDecodable {
    public init(json: JSON) throws {
        let type = try json.getString(at: "type")
        
        switch type {
        case "slowMotionEnabled":
            self = .slowMotionEnabled
        case "framerate":
            do {
                let value = try json.getString(at: "value")
                if let fps = VideoFramerate(rawValue: value) {
                    self = .framerate(fps)
                } else {
                    self = .none
                }
            } catch {
                self = .none
            }
        case "resolution":
            do {
                let value = try json.getString(at: "value")
                if let resolution = VideoResolution(rawValue: value) {
                    self = .resolution(resolution)
                } else {
                    self = .none
                }
            } catch {
                self = .none
            }
        default:
            self = .none
        }
    }
    
    public func toJSON() -> JSON {
        switch self {
        case .none:
            return .dictionary([
                "type": "none"
                ])
        case .slowMotionEnabled:
            return .dictionary([
                "type": "slowMotionEnabled"
                ])
        case .framerate(let fps):
            return .dictionary([
                "type": "framerate",
                "value": fps.toJSON()
                ])
        case .resolution(let resolution):
            return .dictionary([
                "type": "resolution",
                "value": resolution.toJSON()
                ])
        }
    }
}

public enum VideoResolution: String {
    case resolution_640x480
    case resolution_640x512
    case resolution_720p
    case resolution_1080p
    case resolution_2704x1520
    case resolution_2720x1530
    case resolution_3840x1572
    case resolution_4k
    case resolution_4096x2160
    case resolution_5280x2160
    case max
    case noSSDVideo
    case unknown
}

extension VideoResolution: JSONEncodable, JSONDecodable {}

public enum VideoFramerate: String {
    case framerate_23dot976fps
    case framerate_24fps
    case framerate_25fps
    case framerate_29dot970fps
    case framerate_30fps
    case framerate_47dot950fps
    case framerate_48fps
    case framerate_50fps
    case framerate_59dot940fps
    case framerate_60fps
    case framerate_96fps
    case framerate_120fps
    case unknown
}

extension VideoFramerate: JSONEncodable, JSONDecodable {}


// MARK: - CameraTokenError

public enum CameraTokenError: Error {
    case cameraAlreadyInUse
}
