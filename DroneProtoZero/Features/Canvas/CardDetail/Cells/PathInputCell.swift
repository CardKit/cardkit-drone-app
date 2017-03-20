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


protocol PathInputCellDelegate: class {
    func cellSizeUpdated(cell: PathInputCell)
}

class PathInputCell: CardDetailTableViewCell, CardDetailInputCell, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var footer: UIView? //TODO: do I need this?
    
    var type: CardDetailTableViewController.CardDetailTypes?
    weak var delegate: PathInputCellDelegate?
    var inputSlot: InputSlot?
    var points: [CGPoint] = [CGPoint.zero, CGPoint.zero]
    
    private enum CellIdentifiers: String {
        case headerCell = "PathInputHeaderCell"
        case pointCell = "PathInputPointCell"        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
    
    func setupCell(card: ActionCard, indexPath: IndexPath) {
        
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
        header.removeBtn?.addTarget(self, action: #selector(removePoint), for: .touchUpInside)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    // MARK: IBActions
    
    @IBAction func tapAddPoint() {
        addPoint()
    }
    
    // MARK: Instance methods
    
    func addPoint() {
        guard let tableView = self.tableView else {
            return
        }
        points.append(CGPoint.zero)
        
        tableView.beginUpdates()
        let indexSet = IndexSet(integer: tableView.numberOfSections)
        tableView.insertSections(indexSet, with: .none)
        tableView.endUpdates()
        
        updateContainerCell()
    }
    
    func removePoint(sender: UIButton) {
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
