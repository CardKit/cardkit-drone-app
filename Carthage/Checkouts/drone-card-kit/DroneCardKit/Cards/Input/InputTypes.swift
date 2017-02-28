//
//  InputTypes.swift
//  DroneCardKit
//
//  Created by Justin Manweiler on 7/27/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

import Freddy

// MARK: DCKAngle

public struct DCKAngle {
    public static let zero = DCKAngle(degrees: 0)
    
    public let degrees: Double
    
    public var radians: Double {
        return degrees * .pi / 180
    }
    
    public init(degrees: Double) {
        self.degrees = degrees
    }
    
    public init(radians: Double) {
        self.degrees = radians * 180 / .pi
    }
    
    public func normalized() -> DCKAngle {
        let normalizedDegrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
        return DCKAngle(degrees: normalizedDegrees)
    }
}

extension DCKAngle {
    public static func + (lhs: DCKAngle, rhs: DCKAngle) -> DCKAngle {
        return DCKAngle(degrees: lhs.degrees + rhs.degrees)
    }
    
    public static func - (lhs: DCKAngle, rhs: DCKAngle) -> DCKAngle {
        return DCKAngle(degrees: lhs.degrees - rhs.degrees)
    }
    
    public static func * (lhs: DCKAngle, rhs: DCKAngle) -> DCKAngle {
        return DCKAngle(degrees: lhs.degrees * rhs.degrees)
    }
    
    public static func * (lhs: DCKAngle, rhs: Double) -> DCKAngle {
        return DCKAngle(degrees: lhs.degrees * rhs)
    }
    
    public static func * (lhs: Double, rhs: DCKAngle) -> DCKAngle {
        return DCKAngle(degrees: lhs * rhs.degrees)
    }
    
    public static func / (lhs: DCKAngle, rhs: DCKAngle) -> DCKAngle {
        return DCKAngle(degrees: lhs.degrees / rhs.degrees)
    }
    
    public static func / (lhs: DCKAngle, rhs: Double) -> DCKAngle {
        return DCKAngle(degrees: lhs.degrees / rhs)
    }
    
    public static func / (lhs: Double, rhs: DCKAngle) -> DCKAngle {
        return DCKAngle(degrees: lhs / rhs.degrees)
    }
}

extension DCKAngle: Equatable {
    public static func == (lhs: DCKAngle, rhs: DCKAngle) -> Bool {
        return lhs.degrees == rhs.degrees
    }
}

extension DCKAngle: Comparable {
    public static func < (lhs: DCKAngle, rhs: DCKAngle) -> Bool {
        return lhs.degrees < rhs.degrees
    }
}

extension DCKAngle : JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.degrees = try json.getDouble(at: "degrees")
    }
    
    public func toJSON() -> JSON {
        return .dictionary(["degrees": degrees.toJSON()])
    }
}

// MARK: DCKAttitude

public struct DCKAttitude {
    public static let zero = DCKAttitude(yaw: DCKAngle.zero, pitch: DCKAngle.zero, roll: DCKAngle.zero)
    
    public let yaw: DCKAngle
    public let pitch: DCKAngle
    public let roll: DCKAngle
    
    public init(yaw: DCKAngle, pitch: DCKAngle, roll: DCKAngle) {
        self.yaw = yaw
        self.pitch = pitch
        self.roll = roll
    }
    
    public var compassPoint: DCKCardinalDirection {
        return DCKCardinalDirection.byAngle(yaw)
    }
}

extension DCKAttitude {
    public static func + (lhs: DCKAttitude, rhs: DCKAttitude) -> DCKAttitude {
        return DCKAttitude(yaw: lhs.yaw + rhs.yaw, pitch: lhs.pitch + rhs.pitch, roll: lhs.roll + rhs.roll)
    }
    
    public static func - (lhs: DCKAttitude, rhs: DCKAttitude) -> DCKAttitude {
        return DCKAttitude(yaw: lhs.yaw - rhs.yaw, pitch: lhs.pitch - rhs.pitch, roll: lhs.roll - rhs.roll)
    }
}

extension DCKAttitude: Equatable {
    public static func == (lhs: DCKAttitude, rhs: DCKAttitude) -> Bool {
        return lhs.yaw == rhs.yaw
            && lhs.pitch == rhs.pitch
            && lhs.roll == rhs.roll
    }
}

extension DCKAttitude: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.yaw = try json.decode(at: "yaw", type: DCKAngle.self)
        self.pitch = try json.decode(at: "pitch", type: DCKAngle.self)
        self.roll = try json.decode(at: "roll", type: DCKAngle.self)
    }
    
    public func toJSON() -> JSON {
        return .dictionary([
            "yaw": self.yaw.toJSON(),
            "pitch": self.pitch.toJSON(),
            "roll": self.roll.toJSON()
            ])
    }
}

// MARK: DCKCardinalDirection

public enum DCKCardinalDirection: Int {
    // https://en.wikipedia.org/wiki/Points_of_the_compass
    case North = 0
    case NorthByEast = 1
    case NorthNortheast = 2
    case NortheastByNorth = 3
    case Northeast = 4
    case NortheastByEast = 5
    case EastNortheast = 6
    case EastByNorth = 7
    case East = 8
    case EastBySouth = 9
    case EastSoutheast = 10
    case SoutheastByEast = 11
    case Southeast = 12
    case SoutheastBySouth = 13
    case SouthSoutheast = 14
    case SouthByEast = 15
    case South = 16
    case SouthByWest = 17
    case SouthSouthwest = 18
    case SouthwestBySouth = 19
    case Southwest = 20
    case SouthwestByWest = 21
    case WestSouthwest = 22
    case WestBySouth = 23
    case West = 24
    case WestByNorth = 25
    case WestNorthwest = 26
    case NorthwestByWest = 27
    case Northwest = 28
    case NorthwestByNorth = 29
    case NorthNorthwest = 30
    case NorthByWest = 31
    
    private static let step: Double = 360 / 64.0
    
    private var base: Double {
        return DCKCardinalDirection.step * (2 * Double(self.rawValue) - 1)
    }
    
    public var min: DCKAngle {
        return DCKAngle(degrees: base).normalized()
    }
    
    public var azimuth: DCKAngle {
        return DCKAngle(degrees: base + DCKCardinalDirection.step)
    }
    
    public var max: DCKAngle {
        return DCKAngle(degrees: base + DCKCardinalDirection.step * 2)
    }
    
    public static func byAngle(_ angle: DCKAngle) -> DCKCardinalDirection {
        let index: Int = Int(((angle.degrees + DCKCardinalDirection.step) * 32) / 360) % 32
        return DCKCardinalDirection(rawValue: index)!
    }
}

// MARK: DCKDegrees

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

// MARK: DCKCoordinate2D

public struct DCKCoordinate2D {
    static let earthsRadiusInMeters = 6371e3 //in meters
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    /// Finds the distance between two DCKCoordinate2Ds using the haversine formula.
    /// See here for more info: http://www.movable-type.co.uk/scripts/latlong.html
    ///
    /// - Parameter secondCoordinate: second coordinate used for calculating distance
    /// - Returns: returns  in meters
    public func distance(to coordinate: DCKCoordinate2D) -> Double {
        let lat1Rad = self.latitude.degreesToRadians
        let lat2Rad = coordinate.latitude.degreesToRadians
        
        let latDelta = (coordinate.latitude - self.latitude).degreesToRadians
        let lonDelta = (coordinate.longitude - self.longitude).degreesToRadians
        
        let a = sin(latDelta/2) * sin(latDelta/2) +
            cos(lat1Rad) * cos(lat2Rad) *
            sin(lonDelta/2) * sin(lonDelta/2)
        
        let angularDistanceInRadians = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let distance = DCKCoordinate2D.earthsRadiusInMeters * angularDistanceInRadians
        
        return distance
    }
    
    /// Calculates the bearing (angle measureed in clockwise from North) to the second coordinate.
    /// See here for more info: http://www.movable-type.co.uk/scripts/latlong.html
    /// Also see this for more info: http://www.igismap.com/formula-to-find-bearing-or-heading-angle-between-two-points-latitude-longitude/
    ///
    /// - Parameter secondCoordinate: second coordinate used for calculating bearing
    /// - Returns: returns bearing (angle measured in clockwise from North)
    public func bearing(to coordinate: DCKCoordinate2D) -> DCKAngle {
        let lat1Rad = self.latitude.degreesToRadians
        let lat2Rad = coordinate.latitude.degreesToRadians
        
        let lon1Rad = self.longitude.degreesToRadians
        let lon2Rad = coordinate.longitude.degreesToRadians
        
        let y = sin(lon2Rad - lon1Rad) * cos(lat2Rad)
        let x = cos(lat1Rad) * sin(lat2Rad) -
            sin(lat1Rad) * cos(lat2Rad) * cos(lon2Rad - lon1Rad)
        
        let bearing = atan2(y, x).radiansToDegrees
        
        return DCKAngle(degrees: bearing)
    }
}

extension DCKCoordinate2D: Equatable {
    public static func == (lhs: DCKCoordinate2D, rhs: DCKCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
    }
}

extension DCKCoordinate2D: CustomStringConvertible {
    public var description: String {
        return "\(self.latitude), \(self.longitude)"
    }
}

extension DCKCoordinate2D: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.latitude = try json.getDouble(at: "latitude")
        self.longitude = try json.getDouble(at: "longitude")
    }

    public func toJSON() -> JSON {
        return .dictionary([
            "latitude": self.latitude.toJSON(),
            "longitude": self.longitude.toJSON()
            ])
    }
}

// MARK: DCKOrientedCoordinate2D

public struct DCKOrientedCoordinate2D {
    public let latitude: Double
    public let longitude: Double
    public let yaw: DCKAngle
    
    public func asNonOriented() -> DCKCoordinate2D {
        return DCKCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Compute the relative bearing angle between this coordinate (oriented toward its yaw)
    /// and the given coordinate.
    public func bearing(to coordinate: DCKCoordinate2D) -> DCKAngle {
        // calculate the absolute bearing
        let bearing = self.bearing(to: coordinate)
        
        // calculate the relative bearing
        let relativeBearing = bearing - self.yaw
        
        // return the normalized bearing (so negative angles become positive)
        return relativeBearing.normalized()
    }
}

extension DCKOrientedCoordinate2D: Equatable {
    public static func == (lhs: DCKOrientedCoordinate2D, rhs: DCKOrientedCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.yaw == rhs.yaw
    }
}

extension DCKOrientedCoordinate2D: CustomStringConvertible {
    public var description: String {
        return "\(self.latitude), \(self.longitude), \(self.yaw)"
    }
}

extension DCKOrientedCoordinate2D: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.latitude = try json.getDouble(at: "latitude")
        self.longitude = try json.getDouble(at: "longitude")
        self.yaw = try json.decode(at: "yaw", type: DCKAngle.self)
    }
    
    public func toJSON() -> JSON {
        return .dictionary([
            "latitude": self.latitude.toJSON(),
            "longitude": self.longitude.toJSON(),
            "yaw": self.yaw.toJSON()
            ])
    }
}

// MARK: DCKCoordinate3D

public struct DCKCoordinate3D {
    public let latitude: Double
    public let longitude: Double
    public let altitude: DCKRelativeAltitude
    
    public init(latitude: Double, longitude: Double, altitude: DCKRelativeAltitude) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
    
    public func as2D() -> DCKCoordinate2D {
        return DCKCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Compute the bearing angle between this coordinate and the given coordinate. The bearing angle
    /// is the horizontal angle between the two coordinates.  The 3D bearing is the same as the 2D bearing.
    public func bearing(to coordinate: DCKCoordinate3D) -> DCKAngle {
        // calculate 2D bearing
        return self.as2D().bearing(to: coordinate.as2D())
    }
    
    /// Compute the pitch angle between this coordinate and the given coordinate. The pitch angle is
    /// the vertical angle between the two coordinates.
    public func pitch(to coordinate: DCKCoordinate3D) -> DCKAngle {
        // we have the opposite value (change in altitude) and the hypotoneuse (distance to location)
        // sin(theta) = opposite/hypotoneuse .. which is..  sin(theta) = altitude/distance
        let altitudeDelta = coordinate.altitude.metersAboveGroundAtTakeoff - self.altitude.metersAboveGroundAtTakeoff
        let distanceToLocation = self.as2D().distance(to: coordinate.as2D())
        
        // altitudeDelta must be multiplied by -1 to map it correctly to our normalized angles
        // e.g. if altitudeDelta is -20, the end altitude is lower than the current altitude
        // since we need to to rotate downards, the angle must be positive
        let pitchAngle = asin(-1*altitudeDelta/distanceToLocation).radiansToDegrees
        let pitchAngleNormalized = DCKAngle(degrees: pitchAngle).normalized()
        
        return pitchAngleNormalized
    }
}

extension DCKCoordinate3D: Equatable {
    public static func == (lhs: DCKCoordinate3D, rhs: DCKCoordinate3D) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.altitude == rhs.altitude
    }
}

extension DCKCoordinate3D: CustomStringConvertible {
    public var description: String {
        return "\(self.latitude), \(self.longitude), \(self.altitude.metersAboveGroundAtTakeoff)"
    }
}

extension DCKCoordinate3D: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.latitude = try json.getDouble(at: "latitude")
        self.longitude = try json.getDouble(at: "longitude")
        self.altitude = try json.decode(at: "altitude", type: DCKRelativeAltitude.self)
    }

    public func toJSON() -> JSON {
        return .dictionary([
            "latitude": self.latitude.toJSON(),
            "longitude": self.longitude.toJSON(),
            "altitude": self.altitude.toJSON()
            ])
    }
}

// MARK: DCKOrientedCoordinate3D

public struct DCKOrientedCoordinate3D {
    public let latitude: Double
    public let longitude: Double
    public let altitude: DCKRelativeAltitude
    
    /// True North is 0º
    public let yaw: DCKAngle
    
    public func as2D() -> DCKOrientedCoordinate2D {
        return DCKOrientedCoordinate2D(latitude: latitude, longitude: longitude, yaw: yaw)
    }
    
    public func asNonOriented() -> DCKCoordinate3D {
        return DCKCoordinate3D(latitude: latitude, longitude: longitude, altitude: altitude)
    }
    
    /// Compute the relative bearing angle between this coordinate (oriented toward its yaw)
    /// and the given coordinate.
    public func bearing(to coordinate: DCKCoordinate3D) -> DCKAngle {
        // calculate the absolute bearing (true north is 0º)
        let bearing = self.asNonOriented().bearing(to: coordinate)
        
        // calculate the relative bearing
        let relativeBearing = bearing - self.yaw
        
        // return the normalized bearing (so negative angles become positive)
        return relativeBearing.normalized()
    }
}

extension DCKOrientedCoordinate3D: Equatable {
    public static func == (lhs: DCKOrientedCoordinate3D, rhs: DCKOrientedCoordinate3D) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.yaw == rhs.yaw
    }
}

extension DCKOrientedCoordinate3D: CustomStringConvertible {
    public var description: String {
        return "\(self.latitude), \(self.longitude), \(self.altitude.metersAboveGroundAtTakeoff)m"
    }
}

extension DCKOrientedCoordinate3D: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.latitude = try json.getDouble(at: "latitude")
        self.longitude = try json.getDouble(at: "longitude")
        self.altitude = try json.decode(at: "altitude", type: DCKRelativeAltitude.self)
        self.yaw = try json.decode(at: "yaw", type: DCKAngle.self)
    }
    
    public func toJSON() -> JSON {
        return .dictionary([
            "latitude": self.latitude.toJSON(),
            "longitude": self.longitude.toJSON(),
            "altitude": self.altitude.toJSON(),
            "yaw": self.yaw.toJSON()
            ])
    }
}

// MARK: DCKCoordinate2DPath

public struct DCKCoordinate2DPath {
    public let path: [DCKCoordinate2D]
    
    public init(path: [DCKCoordinate2D]) {
        self.path = path
    }
}

extension DCKCoordinate2DPath: Equatable {
    public static func == (lhs: DCKCoordinate2DPath, rhs: DCKCoordinate2DPath) -> Bool {
        return lhs.path == rhs.path
    }
}

extension DCKCoordinate2DPath: CustomStringConvertible {
    public var description: String {
        let strs: [String] = self.path.map { $0.description }
        return strs.joined(separator: ", ")
    }
}

extension DCKCoordinate2DPath: JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.path = try json.decodedArray(type: DCKCoordinate2D.self)
    }
    
    public func toJSON() -> JSON {
        return self.path.toJSON()
    }
}

// MARK: DCKCoordinate3DPath

public struct DCKCoordinate3DPath {
    public let path: [DCKCoordinate3D]
    
    public init(path: [DCKCoordinate3D]) {
        self.path = path
    }
}

extension DCKCoordinate3DPath: CustomStringConvertible {
    public var description: String {
        let strs: [String] = self.path.map { $0.description }
        return strs.joined(separator: ", ")
    }
}
    
extension DCKCoordinate3DPath: JSONEncodable, JSONDecodable {
    public func toJSON() -> JSON {
        return self.path.toJSON()
    }
    
    public init(json: JSON) throws {
        self.path = try json.decodedArray(type: DCKCoordinate3D.self)
    }
}

// MARK: DCKAbsoluteAltitude


public struct DCKAbsoluteAltitude {
    public let metersAboveSeaLevel: Double
    
    public static func + (lhs: DCKAbsoluteAltitude, rhs: DCKAbsoluteAltitude) -> DCKAbsoluteAltitude {
        return DCKAbsoluteAltitude(metersAboveSeaLevel: lhs.metersAboveSeaLevel + rhs.metersAboveSeaLevel)
    }
    
    public static func - (lhs: DCKAbsoluteAltitude, rhs: DCKAbsoluteAltitude) -> DCKAbsoluteAltitude {
        return DCKAbsoluteAltitude(metersAboveSeaLevel: lhs.metersAboveSeaLevel - rhs.metersAboveSeaLevel)
    }
}

extension DCKAbsoluteAltitude: Equatable {
    public static func == (lhs: DCKAbsoluteAltitude, rhs: DCKAbsoluteAltitude) -> Bool {
        return lhs.metersAboveSeaLevel == rhs.metersAboveSeaLevel
    }
}

extension DCKAbsoluteAltitude: Comparable {
    public static func < (lhs: DCKAbsoluteAltitude, rhs: DCKAbsoluteAltitude) -> Bool {
        return lhs.metersAboveSeaLevel < rhs.metersAboveSeaLevel
    }
}

extension DCKAbsoluteAltitude : JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.metersAboveSeaLevel = try json.getDouble(at: "metersAboveSeaLevel")
    }
    
    public func toJSON() -> JSON {
        return .dictionary(["metersAboveSeaLevel": metersAboveSeaLevel.toJSON()])
    }
}

// MARK: DCKRelativeAltitude

public struct DCKRelativeAltitude {
    public let metersAboveGroundAtTakeoff: Double
    
    public init(metersAboveGroundAtTakeoff: Double) {
        self.metersAboveGroundAtTakeoff = metersAboveGroundAtTakeoff
    }
}

extension DCKRelativeAltitude: Equatable {
    public static func == (lhs: DCKRelativeAltitude, rhs: DCKRelativeAltitude) -> Bool {
        return lhs.metersAboveGroundAtTakeoff == rhs.metersAboveGroundAtTakeoff
    }
}

extension DCKRelativeAltitude : JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.metersAboveGroundAtTakeoff = try json.getDouble(at: "metersAboveGroundAtTakeoff")
    }
    
    public func toJSON() -> JSON {
        return .dictionary(["metersAboveGroundAtTakeoff": metersAboveGroundAtTakeoff.toJSON()])
    }
}


// MARK: DCKSpeed

public struct DCKSpeed {
    public let metersPerSecond: Double
    
    private static let mpsToMphConversionFactor: Double = 2.23694
    
    public var milesPerHour: Double {
        return metersPerSecond * DCKSpeed.mpsToMphConversionFactor
    }
    
    public init(metersPerSecond: Double) {
        self.metersPerSecond = metersPerSecond
    }
    
    public init(milesPerHour: Double) {
        self.metersPerSecond = milesPerHour / DCKSpeed.mpsToMphConversionFactor
    }
}

extension DCKSpeed {
    public static func + (lhs: DCKSpeed, rhs: DCKSpeed) -> DCKSpeed {
        return DCKSpeed(metersPerSecond: lhs.metersPerSecond + rhs.metersPerSecond)
    }
    
    public static func - (lhs: DCKSpeed, rhs: DCKSpeed) -> DCKSpeed {
        return DCKSpeed(metersPerSecond: lhs.metersPerSecond - rhs.metersPerSecond)
    }
}

extension DCKSpeed: Equatable {
    public static func == (lhs: DCKSpeed, rhs: DCKSpeed) -> Bool {
        return lhs.metersPerSecond == rhs.metersPerSecond
    }
}

extension DCKSpeed: Comparable {
    public static func < (lhs: DCKSpeed, rhs: DCKSpeed) -> Bool {
        return lhs.metersPerSecond < rhs.metersPerSecond
    }
}

extension DCKSpeed : JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.metersPerSecond = try json.getDouble(at: "metersPerSecond")
    }
    
    public func toJSON() -> JSON {
        return .dictionary(["metersPerSecond": metersPerSecond.toJSON()])
    }
}

// MARK: DCKDistance

public struct DCKDistance {
    public let meters: Double
    
    private static let fooToMeterConversionFactor: Double = 0.3048
    
    public init(meters: Double) {
        self.meters = meters
    }
    
    public init(feet: Double) {
        self.meters = feet * DCKDistance.fooToMeterConversionFactor
    }
}

extension DCKDistance {
    public static func + (lhs: DCKDistance, rhs: DCKDistance) -> DCKDistance {
        return DCKDistance(meters: lhs.meters + rhs.meters)
    }
    
    public static func - (lhs: DCKDistance, rhs: DCKDistance) -> DCKDistance {
        return DCKDistance(meters: lhs.meters - rhs.meters)
    }
}

extension DCKDistance: Equatable {
    public static func == (lhs: DCKDistance, rhs: DCKDistance) -> Bool {
        return lhs.meters == rhs.meters
    }
}

extension DCKDistance: Comparable {
    public static func < (lhs: DCKDistance, rhs: DCKDistance) -> Bool {
        return lhs.meters < rhs.meters
    }
}

extension DCKDistance : JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.meters = try json.getDouble(at: "meters")
    }
    
    public func toJSON() -> JSON {
        return .dictionary(["meters": meters.toJSON()])
    }
}


// MARK: DCKMovementDirection

public struct DCKMovementDirection {
    public let isClockwise: Bool
    
    public init(isClockwise: Bool) {
        self.isClockwise = isClockwise
    }
    
}

extension DCKMovementDirection: Equatable {
    public static func == (lhs: DCKMovementDirection, rhs: DCKMovementDirection) -> Bool {
        return lhs.isClockwise == rhs.isClockwise
    }
}

extension DCKMovementDirection : JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.isClockwise = try json.getBool(at: "isClockwise")
    }
    
    public func toJSON() -> JSON {
        return .dictionary(["isClockwise": isClockwise.toJSON()])
    }
}


// MARK: DCKRotationDirection
public enum DCKRotationDirection {
    case clockwise
    case counterClockwise
}

// MARK: DCKAngularVelocity
public struct DCKAngularVelocity {
    public let degreesPerSecond: Double
    
    public init(degreesPerSecond: Double) {
        self.degreesPerSecond = degreesPerSecond
    }

    public var radiansPerSecond: Double {
        return degreesPerSecond * .pi / 180
    }
    
    public var rotationDirection: DCKRotationDirection {
        return degreesPerSecond < 0 ? .counterClockwise : .clockwise
    }
}

extension DCKAngularVelocity {
    public static func + (lhs: DCKAngularVelocity, rhs: DCKAngularVelocity) -> DCKAngularVelocity {
        return DCKAngularVelocity(degreesPerSecond: lhs.degreesPerSecond + rhs.degreesPerSecond)
    }
    
    public static func - (lhs: DCKAngularVelocity, rhs: DCKAngularVelocity) -> DCKAngularVelocity {
        return DCKAngularVelocity(degreesPerSecond: lhs.degreesPerSecond - rhs.degreesPerSecond)
    }
}

extension DCKAngularVelocity: Equatable {
    public static func == (lhs: DCKAngularVelocity, rhs: DCKAngularVelocity) -> Bool {
        return lhs.degreesPerSecond == rhs.degreesPerSecond
    }
}

extension DCKAngularVelocity: Comparable {
    public static func < (lhs: DCKAngularVelocity, rhs: DCKAngularVelocity) -> Bool {
        return lhs.degreesPerSecond < rhs.degreesPerSecond
    }
}

extension DCKAngularVelocity : JSONDecodable, JSONEncodable {
    public init(json: JSON) throws {
        self.degreesPerSecond = try json.getDouble(at: "degreesPerSecond")
    }
    
    public func toJSON() -> JSON {
        return .dictionary(["degreesPerSecond": degreesPerSecond.toJSON()])
    }
}

// MARK: DCKFrequency

public struct DCKFrequency {
    public let hertz: Double
    
    //https://en.wikipedia.org/wiki/Hertz

    public var kilohertz: Double {
        return hertz / 1000
    }
    
    public var megahertz: Double {
        return hertz / 1000000
    }
    
    public init(hertz: Double) {
        self.hertz = hertz
    }
    
    public init(kilohertz: Double) {
        self.hertz = kilohertz * 1000
    }
    
    public init(megahertz: Double) {
        self.hertz = megahertz * 1000000
    }
}

extension DCKFrequency {
    public static func + (lhs: DCKFrequency, rhs: DCKFrequency) -> DCKFrequency {
        return DCKFrequency(hertz: lhs.hertz + rhs.hertz)
    }
    
    public static func * (lhs: DCKFrequency, rhs: Double) -> DCKFrequency {
        return DCKFrequency(hertz: lhs.hertz * rhs)
    }
    
    public static func * (lhs: Double, rhs: DCKFrequency) -> DCKFrequency {
        return DCKFrequency(hertz: lhs * rhs.hertz)
    }
    
    public static func / (lhs: DCKFrequency, rhs: Double) -> DCKFrequency {
        return DCKFrequency(hertz: lhs.hertz / rhs)
    }
    
    public static func / (lhs: Double, rhs: DCKFrequency) -> DCKFrequency {
        return DCKFrequency(hertz: lhs / rhs.hertz)
    }
}

extension DCKFrequency: Equatable {
    public static func == (lhs: DCKFrequency, rhs: DCKFrequency) -> Bool {
        return lhs.hertz == rhs.hertz
    }
}

extension DCKFrequency: Comparable {
    public static func < (lhs: DCKFrequency, rhs: DCKFrequency) -> Bool {
        return lhs.hertz < rhs.hertz
    }
}
