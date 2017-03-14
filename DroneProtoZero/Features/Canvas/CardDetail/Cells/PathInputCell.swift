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
    
    var points: [CGPoint] = []
    
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
        return 2
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
        print("header label \(header.label?.text)")
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 90.0))
//    }
    
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
    
}

class PathInputPointCell: UITableViewCell, Reusable {
    
    @IBOutlet weak var latitudeLabel: UILabel?
    @IBOutlet weak var longitudeLabel: UILabel?
    @IBOutlet weak var latitudeInput: UITextField?
    @IBOutlet weak var longitudeInput: UITextField?
    
}


