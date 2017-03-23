//
//  Location2DInput.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/3/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//
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
        if let card = self.actionCard,
            let inputSlot = self.inputSlot {
            if let val: DCKCoordinate2D = card.value(of: inputSlot) {
                flyToLocation?.coordinate = CLLocationCoordinate2D(latitude: val.latitude, longitude: val.longitude)
                latitudeTextField?.text = "\(val.latitude)"
                longitudeTextField?.text = "\(val.longitude)"
            }
        }
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
        print("user location \(userLocation)")
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
        guard let latitudeText = latitudeTextField?.text, latitudeText != "",
            let longitudeText = longitudeTextField?.text, longitudeText != "",
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
        guard let latitudeText = latitudeTextField?.text, latitudeText != "",
            let longitudeText = longitudeTextField?.text, longitudeText != "",
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
        guard let latitudeText = latitudeTextField?.text, latitudeText != "",
            let longitudeText = longitudeTextField?.text, longitudeText != "",
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
        guard let latitudeText = latitudeTextField?.text, latitudeText != "",
            let longitudeText = longitudeTextField?.text, longitudeText != "",
            let altitudeText = altitudeTextField?.text, altitudeText != "",
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
