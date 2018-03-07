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

import UIKit
import CardKit
import MapKit
import DroneCardKit

class Location2DInput: CardDetailTableViewCell, CardDetailInputCell, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView?
    @IBOutlet weak var latitudeTextField: UITextField?
    @IBOutlet weak var longitudeTextField: UITextField?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var actionCard: ActionCard?
    var inputSlot: InputSlot?
    
    let visibleDistance: CLLocationDistance = 1000 //meters
    var flyToLocation: MKPointAnnotation?
    var flyToAnnotationView: MKAnnotationView?
    
    override func awakeFromNib() {
        
        latitudeTextField?.delegate = self
        longitudeTextField?.delegate = self
    
        map?.delegate = self
        map?.showsUserLocation = true
        
        //gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(gesture:)))
        map?.addGestureRecognizer(tapGesture)
        
        setupMap()
    }
    
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        self.actionCard = card
        
        setSelectedInputOptions()
    }
    
    func setupMap() {
        
        flyToLocation = MKPointAnnotation()
        flyToAnnotationView = MKAnnotationView()
        flyToAnnotationView?.image = UIImage(named: "Map Point Annotation")
        if let flyToLoc = flyToLocation {
            map?.addAnnotation(flyToLoc)
        }
    }
    
    func setSelectedInputOptions() {
        guard let card = self.actionCard,
            let inputSlot = self.inputSlot,
            let val: DCKCoordinate2D = card.value(of: inputSlot) else {
            return
        }
        
        flyToLocation?.coordinate = CLLocationCoordinate2D(latitude: val.latitude, longitude: val.longitude)
        latitudeTextField?.text = "\(val.latitude)"
        longitudeTextField?.text = "\(val.longitude)"        
    }
    
    // MARK: - Instance Methods
    
    func onTap(gesture: UITapGestureRecognizer) {
        
        if gesture.state == .ended {
            let touchLocation = gesture.location(ofTouch: 0, in: map)
            if let mapCoordinates = map?.convert(touchLocation, toCoordinateFrom: map) {
                flyToLocation?.coordinate = mapCoordinates
                latitudeTextField?.text = "\(mapCoordinates.latitude)"
                longitudeTextField?.text = "\(mapCoordinates.longitude)"
            
                saveToCard(coordinate: createInput())
                
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {        
        map?.setCenter(userLocation.coordinate, animated: false)
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, visibleDistance, visibleDistance)
        let rect = MKMapRect.rectForCoordinateRegion(region: region)
        map?.setVisibleMapRect(rect, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(flyToLocation) {
            return flyToAnnotationView
        }
        
        return nil
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let latitudeText = latitudeTextField?.text, !latitudeText.isEmpty,
            let longitudeText = longitudeTextField?.text, !longitudeText.isEmpty,
            let latitude = Double(latitudeText),
            let longitude = Double(longitudeText),
            let flyToLoc = flyToLocation else {
                return
        }
        
        //set fly to point in map
        flyToLoc.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        saveToCard(coordinate: createInput())
        
    }
    
    // MARK: - Instance methods
    
    func createInput() -> Any? {
        guard let latitudeText = latitudeTextField?.text, !latitudeText.isEmpty,
            let longitudeText = longitudeTextField?.text, !longitudeText.isEmpty,
            let latitude = Double(latitudeText),
            let longitude = Double(longitudeText) else {
                return nil
        }
        
        let coordinate2D = DCKCoordinate2D(latitude: latitude, longitude: longitude)
        return coordinate2D
    }
    
    func saveToCard(coordinate: Any?) {
        guard let inputSlot = self.inputSlot,
            let actionCard = self.actionCard,
            let coordinate = coordinate else {
            return
        }
        do {
            let inputCard = try inputSlot.descriptor <- coordinate
            try actionCard.bind(with: inputCard, in: inputSlot)
        } catch {
            print("error \(error)")
        }
        
    }
}

class Location3DInput: Location2DInput {
    
    @IBOutlet weak var altitudeTextField: UITextField?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        altitudeTextField?.delegate = self
    }
    
    override func setSelectedInputOptions() {
        if let card = self.actionCard,
            let inputSlot = self.inputSlot {
            if let val: DCKCoordinate3D = card.value(of: inputSlot) {
                flyToLocation?.coordinate = CLLocationCoordinate2D(latitude: val.latitude, longitude: val.longitude)
                latitudeTextField?.text = "\(val.latitude)"
                longitudeTextField?.text = "\(val.longitude)"
                altitudeTextField?.text = "\(val.altitude.metersAboveGroundAtTakeoff)"
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard let latitudeText = latitudeTextField?.text, !latitudeText.isEmpty,
            let longitudeText = longitudeTextField?.text, !longitudeText.isEmpty,
            let latitude = Double(latitudeText),
            let longitude = Double(longitudeText),
            let flyToLoc = flyToLocation else {
                return
        }
        
        //set fly to point in map
        flyToLoc.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        saveToCard(coordinate: createInput())
        
    }
    
    // MARK: - Instance methods
    
    override func createInput() -> Any? {
        guard let latitudeText = latitudeTextField?.text, !latitudeText.isEmpty,
            let longitudeText = longitudeTextField?.text, !longitudeText.isEmpty,
            let altitudeText = altitudeTextField?.text, !altitudeText.isEmpty,
            let latitude = Double(latitudeText),
            let longitude = Double(longitudeText),
            let altitude = Double(altitudeText) else {
                return nil
        }
        
        let dckAltitude = DCKRelativeAltitude(metersAboveGroundAtTakeoff: altitude)
        let coordinate3D = DCKCoordinate3D(latitude: latitude, longitude: longitude, altitude: dckAltitude)
        return coordinate3D
    }
    
}
