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

class Location2DInput: CardDetailTableViewCell, CardDetailInputCell {
    
    @IBOutlet weak var map: MKMapView?
    @IBOutlet weak var latitudeTextField: UITextField?
    @IBOutlet weak var longitudeTextField: UITextField?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var inputSlot: InputSlot?
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        print("location2DInput setupCell")
        print(self.frameView?.subviews)
    }
}

class Location3DInput: Location2DInput {
    
    @IBOutlet weak var altitudeTextField: UITextField?
    
}
