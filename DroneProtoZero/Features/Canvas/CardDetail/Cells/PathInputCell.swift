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

class PathInputCell: CardDetailTableViewCell, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var footerView: UIView?
    
    var points: [CGPoint] = [CGPoint.zero, CGPoint.zero]
    
    private enum CellIdentifiers: String {
        case headerCell = "PathInputHeaderCell"
        case pointCell = "PathInputPointCell"        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tableView?.tableFooterView = footerView
//        tableView?.tableFooterView = tableView?.dequeueReusableCell(withIdentifier: CellIdentifiers.footer.rawValue)
//        tableView?.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: (tableView?.frame.size.width)!, height: 90.0))//tableView?.dequeueReusableCell(withIdentifier: CellIdentifiers.footer.rawValue)
//        tableView?.tableFooterView?.backgroundColor = UIColor.red
        print("tableFooterView \(tableView?.tableFooterView)")
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 90.0
    }

    override func setupCell(cardDescriptor: ActionCardDescriptor) {
        super.setupCell(cardDescriptor: cardDescriptor)
    }
    
    //MARK: - UITableView
    
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
        guard let header = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.headerCell.rawValue) as? PathInputHeader else {
            return nil
        }
        
        header.label?.text = "POINT \(section + 1)"
        header.section = section
        header.removeBtn?.addTarget(self, action: #selector(removePoint), for: .touchUpInside)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    //MARK: - IBActions
    
    @IBAction func tapAddPoint() {
        self.addPoint()
        
    }
    
    //MARK: - Instance methods
    
    func addPoint() {
        guard let tableView = self.tableView else {
            return
        }
        tableView.beginUpdates()
        let indexSet = IndexSet(integer: tableView.numberOfSections)
        points.append(CGPoint.zero)
        tableView.insertSections(indexSet, with: .none)
        tableView.endUpdates()
    }
    
    func removePoint(sender: UIButton) {
        guard let header = sender.superview?.superview as? PathInputHeader,
            let section = header.section else {
            return
        }
        tableView?.beginUpdates()
        let indexSet = IndexSet(integer: section)
        points.remove(at: section)
        tableView?.deleteSections(indexSet, with: .top)
        tableView?.endUpdates()
    }
}


class PathInputTableView: UITableView {
    //needed to force the parent tableViewCell to size itself dynamically according to table height
    //http://stackoverflow.com/questions/42529312/adding-uitableview-inside-uitableviewcell-tableview-height-making-based-on-cont
    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }
}

class PathInputHeader: UITableViewCell, Reusable {
    
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


