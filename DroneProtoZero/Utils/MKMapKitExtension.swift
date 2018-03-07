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
