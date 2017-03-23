//
//  MKMapKitExtension.swift
//  DroneProtoZero
//  
//  from: http://stackoverflow.com/questions/9270268/convert-mkcoordinateregion-to-mkmaprect
//  
//  Created by Kristina M Brimijoin on 3/21/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import MapKit

extension MKMapRect {
    static func rectForCoordinateRegion(region: MKCoordinateRegion) -> MKMapRect {
        let a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
            region.center.latitude + region.span.latitudeDelta / 2,
            region.center.longitude - region.span.longitudeDelta / 2))
        let b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
            region.center.latitude - region.span.latitudeDelta / 2,
            region.center.longitude + region.span.longitudeDelta / 2))
        
        return MKMapRectMake(min(a.x, b.x), min(a.y, b.y), abs(a.x-b.x), abs(a.y-b.y))
    }
    
}
