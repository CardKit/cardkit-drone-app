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

class PathInputCell: CardDetailTableViewCell, CardDetailInputCell, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var map: MKMapView?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    weak var delegate: PathInputCellDelegate?
    var inputSlot: InputSlot?
    
    let visibleDistance: CLLocationDistance = 1000 //meters
    let waypointAnnotationViewIdentifier = "Waypoint"
    var points: [CLLocationCoordinate2D] = []
    var polyline: MKPolyline?
    
    var numSections: Int = 2 //always show two cell inputs by default (the minimum number of waypoints required for a path)
    
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
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.pointCell.rawValue, for: indexPath)
        
        if let pathInputPointCell = cell as? PathInputPointCell {
print("cellForRow at \(indexPath)    pointsCount \(points.count)")
            pathInputPointCell.latitudeInput?.delegate = self
            pathInputPointCell.longitudeInput?.delegate = self
            if indexPath.section >= points.count {
print("set cell to empty text")
                pathInputPointCell.latitudeInput?.text = ""
                pathInputPointCell.longitudeInput?.text = ""
            } else {
                let point = points[indexPath.section]
                pathInputPointCell.latitudeInput?.text = "\(point.latitude)"
                pathInputPointCell.longitudeInput?.text = "\(point.longitude)"
            }
        }
    
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
        header.removeBtn?.addTarget(self, action: #selector(tapRemovePointCell(sender:)), for: .touchUpInside)
        
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
        
        map?.setCenter(userLocation.coordinate, animated: false)
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, visibleDistance, visibleDistance)
        let rect = MKMapRect.rectForCoordinateRegion(region: region)
        map?.setVisibleMapRect(rect, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !annotation.isKind(of: MKUserLocation.self) {
            var waypointView = mapView.dequeueReusableAnnotationView(withIdentifier: waypointAnnotationViewIdentifier) as? PathInputAnnotationView
            
            if waypointView == nil {
                waypointView = Bundle.main.loadNibNamed("PathInputAnnotationView", owner: nil, options: nil)?.first as? PathInputAnnotationView
            }
            
            if let index = indexForCoordinate(coordinate: annotation.coordinate), index != -1 {
                waypointView?.label?.text = "\(index + 1)"
            }
            
            waypointView?.detailCalloutAccessoryView = calloutViewForAnnotation(annotation: annotation)
            waypointView?.canShowCallout = true
            
            return waypointView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("renderer for \(overlay)")
        if overlay is MKPolyline {
            guard let line = self.polyline else {
                return MKOverlayRenderer()
            }
            print("polyline points \(self.polyline?.points())")
            print("polyline pointsCount \(self.polyline?.pointCount)")
            let renderer = MKPolylineRenderer(polyline: line)
            renderer.fillColor = .black
            renderer.strokeColor = .black
            renderer.lineWidth = 3
            print("return the rendered line")
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //ensure both textfields have content that can be converted to a CLLocationDegrees (Double)
        //before adding to a map
        if let cell = textField.superview?.superview as? PathInputPointCell {
            
            guard let latitudeInput = cell.latitudeInput?.text, latitudeInput != "",
                let longitudeInput = cell.longitudeInput?.text, longitudeInput != "",
                let lat = Double(latitudeInput),
                let long = Double(longitudeInput) else {
                    return
            }
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            addMapPoint(at: coordinate)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let numericalInput = textField as? CardInputField, numericalInput.isNumericalOnly {
            return numericalInput.validateNumericalOnly(inputText: string)
        }
        return true
    }
    
    // MARK: - IBActions
    
    @IBAction func tapAddPoint() {
        addPointCell()
    }
    
    // MARK: - Point Cells
    
    func addPointCell(coordinate: CLLocationCoordinate2D? = nil) {
        guard let tableView = self.tableView else {
            return
        }
        
        if let point = coordinate,
            let index = indexForCoordinate(coordinate: point) {            
            print("index \(index)")
            if index >= tableView.numberOfSections {
                //no cell yet exists for the point, so create one
                insertEmptyPointCell()
            }

        } else {
            insertEmptyPointCell()
        }
        
        updateContainerCell()
    }
    
    func insertEmptyPointCell() {
        print("insert empty point cell")
        guard let tableView = self.tableView else {
            return
        }
        
        tableView.beginUpdates()
        let indexSet = IndexSet(integer: tableView.numberOfSections)
        tableView.insertSections(indexSet, with: .none)
        numSections += 1
        tableView.endUpdates()
        
    }
    
    func tapRemovePointCell(sender: UIButton) {
        guard let header = sender.superview as? PathInputHeader,
            let section = header.section else {
            return
        }
        if section < points.count {
            points.remove(at: section)
        }
        
        deletePointCell(in: section)
    }
    
    func deletePointCell(in section: Int) {
        guard let tableView = self.tableView else {
            return
        }
        tableView.beginUpdates()
        let indexSet = IndexSet(integer: section)
        tableView.deleteSections(indexSet, with: .top)
        numSections -= 1
        tableView.endUpdates()
        
        refreshAnnotations()
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
    
    // MARK: - Points on Map
    
    func onLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            let touchLocation = gesture.location(ofTouch: 0, in: map)
            if let mapCoordinates = map?.convert(touchLocation, toCoordinateFrom: map) {
                addMapPoint(at: mapCoordinates)
            }
        }
    }
    
    func tapRemovePoint(sender: RemoveWaypointButton) {
        if let annotation = sender.annotation {
            removeMapPoint(at: annotation.coordinate)
        }
    }
    
    
    func addMapPoint(at coordinate: CLLocationCoordinate2D) {
        points.append(coordinate)
        addPointCell(coordinate: coordinate)
        refreshAnnotations()
        
    }
    
    func removeMapPoint(at coordinate: CLLocationCoordinate2D) {
        if let index = indexForCoordinate(coordinate: coordinate), index != -1 {
            points.remove(at: index)
            deletePointCell(in: index)
            refreshAnnotations()
        }
    }
    
    func refreshAnnotations() {
        guard let annotations = map?.annotations else {
            return
        }
        map?.removeAnnotations(annotations)
        for point in points {
            let annotation = MKPointAnnotation()
            annotation.coordinate = point
            annotation.title = "Point \(points.count)" //must set title or detail view will not show
            map?.addAnnotation(annotation)
        }
        
        if let line = self.polyline {
            map?.remove(line)
        }
        
        let newLine = MKPolyline(coordinates: &points, count: points.count)
        newLine.title = "Path line"
        map?.add(newLine, level: MKOverlayLevel.aboveLabels)
        self.polyline = newLine
        print("polyline points \(polyline?.points())")
        print("polyline point count \(polyline?.pointCount)")
    }
    
    func indexForCoordinate(coordinate: CLLocationCoordinate2D) -> Int? {
        return points.index(where: { (item) -> Bool in
            return item.latitude == coordinate.latitude && item.longitude == coordinate.longitude
        })
    }
    
    func calloutViewForAnnotation(annotation: MKAnnotation) -> UIView? {
        
        let removeButton = RemoveWaypointButton(frame: CGRect(x: 0, y: 0, width: 174, height: 46))
        let widthConstraint = NSLayoutConstraint(item: removeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 174.0)
        let heightConstraint = NSLayoutConstraint(item: removeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 46.0)
        removeButton.addConstraints([widthConstraint, heightConstraint])
        removeButton.annotation = annotation
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
    
//    override func prepareForReuse() {
//        guard let latInput = latitudeInput,
//            let longInput = longitudeInput else {
//                return
//        }
//        latInput.text = ""
//        longInput.text = ""
//    }
}

class PathInputTableFooter: UIView {
    @IBOutlet weak var button: UIButton?
}

class PathInputAnnotationView: MKAnnotationView {
    @IBOutlet weak var label: UILabel?
}

class RemoveWaypointButton: UIButton {
    var annotation: MKAnnotation?
}
