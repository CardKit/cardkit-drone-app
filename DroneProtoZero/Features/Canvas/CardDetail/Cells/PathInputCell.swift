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
import UIKit
import CardKit
import MapKit
import DroneCardKit


protocol PathInputCellDelegate: class {
    func cellSizeUpdated(cell: PathInputCell)
}

class PathInputCell: CardDetailTableViewCell, CardDetailInputCell, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var map: MKMapView?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    var actionCard: ActionCard?
    var inputSlot: InputSlot?
    weak var delegate: PathInputCellDelegate?
    
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
        self.actionCard = card
        
        setSelectedInputOptions()
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
    
    func saveToCard() {
        guard let inputSlot = self.inputSlot,
            let actionCard = self.actionCard else {
            return
        }
        let dckCoordinates = points.map({ (coordinate) -> DCKCoordinate2D in
            return DCKCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        })
        let path = DCKCoordinate2DPath(path: dckCoordinates)
        do {
            let inputCard = try inputSlot.descriptor <- path
            try actionCard.bind(with: inputCard, in: inputSlot)
        } catch {
            print("error \(error)")
        }
    }
    
    func setSelectedInputOptions() {
        guard let card = self.actionCard,
            let inputSlot = self.inputSlot,
            let val: DCKCoordinate2DPath = card.value(of: inputSlot) else {
                return
        }
        
        self.points = val.path.map({ (coordinate) -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        })
        if points.count > 0 {
            numSections = points.count
        }
        refreshAnnotations()
        updateContainerCell()
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
            pathInputPointCell.latitudeInput?.delegate = self
            pathInputPointCell.longitudeInput?.delegate = self
            if indexPath.section >= points.count {
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

        if overlay is MKPolyline {
            guard let line = self.polyline else {
                return MKOverlayRenderer()
            }

            let renderer = MKPolylineRenderer(polyline: line)
            renderer.strokeColor = .black
            renderer.lineWidth = 3
 
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //ensure both textfields have content that can be converted to a CLLocationDegrees (Double)
        //before adding to a map
        guard let cell = textField.superview?.superview as? PathInputPointCell,
            let latitudeInput = cell.latitudeInput?.text, latitudeInput != "",
            let longitudeInput = cell.longitudeInput?.text, longitudeInput != "",
            let lat = Double(latitudeInput),
            let long = Double(longitudeInput) else {
                return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        addMapPoint(at: coordinate)
        saveToCard()        
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
        saveToCard()
        
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
