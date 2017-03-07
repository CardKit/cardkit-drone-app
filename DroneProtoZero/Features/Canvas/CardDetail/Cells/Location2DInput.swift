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

class Location2DInput: CardDetailTableViewCell {
    
    @IBOutlet weak var map: MKMapView?
    @IBOutlet weak var latitudeTextField: UITextField?
    @IBOutlet weak var longitudeTextField: UITextField?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        
        
    }
    
    override func setupCell(cardDescriptor: ActionCardDescriptor) {
        super.setupCell(cardDescriptor: cardDescriptor)
    }
    
}
