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

class Location2DInput: CardDetailTableViewCell, CardDetailInputCell, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var map: MKMapView?
    @IBOutlet weak var latitudeTextField: UITextField?
    @IBOutlet weak var longitudeTextField: UITextField?
    
    var type: CardDetailTableViewController.CardDetailTypes?
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
        
    }
    
    func setupMap() {
        
        flyToLocation = MKPointAnnotation()
        flyToAnnotationView = MKAnnotationView()
        flyToAnnotationView?.image = UIImage(named: "Map Point Annotation")
        if let flyToLoc = flyToLocation {
            map?.addAnnotation(flyToLoc)
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
        
        //TODO: save lat, long, alt in card
        
    }
}

class Location3DInput: Location2DInput {
    
    @IBOutlet weak var altitudeTextField: UITextField?
    
    // MARK: - UITextFieldDelegate
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard let latitudeText = latitudeTextField?.text, latitudeText != "",
            let longitudeText = longitudeTextField?.text, longitudeText != "",
            let altitudeText = altitudeTextField?.text, altitudeText != "",
            let latitude = Double(latitudeText),
            let longitude = Double(longitudeText),
            let altitude = Double(altitudeText),
            let flyToLoc = flyToLocation else {
                return
        }
        
        //set fly to point in map
        flyToLoc.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //TODO: save lat, long, alt in card
        
    }
    
}
