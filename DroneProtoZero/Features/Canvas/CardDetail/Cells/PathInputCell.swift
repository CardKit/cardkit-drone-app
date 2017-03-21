//
//  PathInputCell.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/13/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import UIKit
import CardKit
import MapKit


protocol PathInputCellDelegate: class {
    func cellSizeUpdated(cell: PathInputCell)
}

class PathInputCell: CardDetailTableViewCell, CardDetailInputCell, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var map: MKMapView?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    weak var delegate: PathInputCellDelegate?
    var inputSlot: InputSlot?
    
    let visibleDistance: CLLocationDistance = 1000 //meters
    let waypointAnnotationViewIdentifier = "Waypoint"
    var points: [CLLocationCoordinate2D] = []
    
    private enum CellIdentifiers: String {
        case headerCell = "PathInputHeaderCell"
        case pointCell = "PathInputPointCell"        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTableView()
        setupMapView()
    }
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        
    }
    
    func setupTableView() {
        if let footerView = Bundle.main.loadNibNamed("PathInputFooter", owner: nil, options: nil)?.first as? PathInputTableFooter {
            footerView.button?.addTarget(self, action: #selector(tapAddPoint), for: .touchUpInside)
            //need this flexibleWidth setting or the height of the footerView is incorrect.  no idea why this works, since it is the
            //height we are concerned with and not the width
            footerView.autoresizingMask = [.flexibleWidth]
            tableView?.tableFooterView = footerView
        }
        
        tableView?.separatorStyle = .none //not working, bug: https://forums.developer.apple.com/thread/12387
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 100.0
    }
    
    func setupMapView() {
        
        map?.delegate = self
        map?.showsUserLocation = true
        
        //gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(gesture:)))        
        map?.addGestureRecognizer(longPressGesture)
    
    }
    
    // MARK: UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {        
        return points.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.pointCell.rawValue, for: indexPath)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //cannot create header from dequeueReusableCell because this tableView has insertions and deletions;
        //tableView expects an indexPath on the header view if it is created via prototype cell;
        guard let header =  Bundle.main.loadNibNamed("PathInputSectionHeader", owner: nil, options: nil)?.first as? PathInputHeader else {
            return nil
        }
        
        header.label?.text = "POINT \(section + 1)"        
        header.section = section
        header.removeBtn?.addTarget(self, action: #selector(removePointCell), for: .touchUpInside)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
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
        print("annotation \(annotation)")
//        if annotation.isEqual(flyToLocation) {
//            return flyToAnnotationView
//        }
        
        if !annotation.isKind(of: MKUserLocation.self) {
            var waypointView = mapView.dequeueReusableAnnotationView(withIdentifier: waypointAnnotationViewIdentifier) as? PathInputAnnotationView
            
            if waypointView == nil {
                waypointView = Bundle.main.loadNibNamed("PathInputAnnotationView", owner: nil, options: nil)?.first as? PathInputAnnotationView
            }
            
            if let index = points.index(where: { (item) -> Bool in
                return item.latitude == annotation.coordinate.latitude && item.longitude == annotation.coordinate.longitude
            }) {
                print("index \(index)")
                waypointView?.label?.text = "\(index + 1)"
            }
            waypointView?.detailCalloutAccessoryView = calloutViewForAnnotation(annotation: annotation)
            waypointView?.canShowCallout = true
            
            return waypointView
        }
        
        return nil
    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        print("selected view!")
//    }
    
    // MARK: IBActions
    
    @IBAction func tapAddPoint() {
        addPointCell()
    }
    
    // MARK: Instance methods
    
    func addPointCell() {
        guard let tableView = self.tableView else {
            return
        }

        tableView.beginUpdates()
        let indexSet = IndexSet(integer: tableView.numberOfSections)
        tableView.insertSections(indexSet, with: .none)
        tableView.endUpdates()
        
        updateContainerCell()
    }
    
    func removePointCell(sender: UIButton) {
        guard let tableView = self.tableView,
            let header = sender.superview as? PathInputHeader,
            let section = header.section else {
            return
        }
        points.remove(at: section)
        
        tableView.beginUpdates()
        let indexSet = IndexSet(integer: section)
        tableView.deleteSections(indexSet, with: .top)
        tableView.endUpdates()
        
        updateContainerCell()
    }
    
    func updateContainerCell() {
        //shouldn't have to reloadData() after beginUpdates() and endUpdates() but the outer cell
        //doesn't resize properly without this call.
        tableView?.reloadData()
        tableView?.separatorStyle = .none //not working, bug: https://forums.developer.apple.com/thread/12387
        
        tableView?.invalidateIntrinsicContentSize()
        if let delegate = self.delegate {
            delegate.cellSizeUpdated(cell: self)
        }
    }
    
    func onLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            let touchLocation = gesture.location(ofTouch: 0, in: map)
            if let mapCoordinates = map?.convert(touchLocation, toCoordinateFrom: map) {
                points.append(mapCoordinates)
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapCoordinates
                annotation.title = "Point \(points.count)" //must set title or detail view will not show
                
                map?.addAnnotation(annotation)
                print("points array \(points)")
            }
        }
    }
    
    func tapRemovePoint(sender: UIButton) {
        print("sender superview \(sender.superview?.superview)")
        print("sender superview \(sender.superview?.superview?.superview)")
    }
    
    func addMapPoint(at coordinate: CLLocationCoordinate2D) {
        
    }
    
    func removeMapPoint(at coordinate: CLLocationCoordinate2D) {
        
    }
    
    func calloutViewForAnnotation(annotation: MKAnnotation) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 174.0, height: 136.0))
//        let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0)
//        let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0)
//        view.addConstraints([widthConstraint, heightConstraint])
        
        let removeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 174, height: 46))
        let widthConstraint = NSLayoutConstraint(item: removeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 174.0)
        let heightConstraint = NSLayoutConstraint(item: removeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 46.0)
        removeButton.addConstraints([widthConstraint, heightConstraint])
        removeButton.setTitle("Remove", for: .normal)
        removeButton.setTitleColor(.black, for: .normal)
        removeButton.titleLabel?.textAlignment = .center
        removeButton.layer.borderColor = UIColor.tableViewSeparatorGray.cgColor
        removeButton.backgroundColor = UIColor.annotationDetailViewGray
        removeButton.addTarget(self, action: #selector(tapRemovePoint(sender:)), for: .touchUpInside)
        
        return removeButton
    }

}



class PathInputTableView: UITableView {
    //needed to force the parent tableViewCell to size itself dynamically according to table height
    //http://stackoverflow.com/questions/42529312/adding-uitableview-inside-uitableviewcell-tableview-height-making-based-on-cont
    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }
}

class PathInputHeader: UIView {
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var removeBtn: UIButton?
    
    var section: Int?
}

class PathInputPointCell: UITableViewCell, Reusable {
    @IBOutlet weak var latitudeLabel: UILabel?
    @IBOutlet weak var longitudeLabel: UILabel?
    @IBOutlet weak var latitudeInput: UITextField?
    @IBOutlet weak var longitudeInput: UITextField?
}

class PathInputTableFooter: UIView {
    @IBOutlet weak var button: UIButton?
}

class PathInputAnnotationView: MKAnnotationView {
    @IBOutlet weak var label: UILabel?
}
