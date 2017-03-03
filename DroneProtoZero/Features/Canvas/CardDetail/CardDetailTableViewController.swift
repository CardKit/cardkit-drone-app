//
//  CardDetailTableViewController.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/2/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class CardDetailTableViewController: UITableViewController {
    
    
    var cardDescriptor: ActionCardDescriptor? {
        didSet {
            guard let descriptor = cardDescriptor else {
                return
            }
            if descriptor.endDescription != "" {
                detailSections.append(.endDetailsCell)
            }
            if descriptor.yields.count > 0 {
                detailSections.append(.outputsCell)
            }
            
            print("inputs \(descriptor.inputSlots)")
            for input in descriptor.inputSlots {
                print("input \(input)")
                if input.descriptor.name == "Coordinate 2D" {
                    detailSections.append(.location2DInput)
                }
            }
        }
    }
    
    private var detailSections: [CellIdentifiers] = [.nameCell, .descriptionCell]
    
    private enum CellIdentifiers: Int {
        case nameCell
        case descriptionCell
        case endDetailsCell
        case outputsCell
        case location2DInput
        case header
        
        var reuseIdentifier: String {
            switch self {
            case .nameCell:
                return "NameCell"
            case .descriptionCell, .endDetailsCell, .outputsCell:
                return "DescriptionCell"
            case .location2DInput:
                return "Location2DInputCell"
            case .header:
                return "Header"
            }            
        }
        
        func headerName() -> String {
            switch self {
            case .nameCell:
                return "Card Name"
            case .descriptionCell:
                return "Description"
            case .endDetailsCell:
                return "End Details"
            case .outputsCell:
                return "Outputs"
            case .location2DInput:
                return "Input: Destination"
            case .header:
                return ""
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInset = UIEdgeInsets(top: 40.0, left: 0.0, bottom: 0.0, right: 0.0)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let numSections = detailSections.count
print("SECTIONS: \(numSections)")
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String = detailSections[indexPath.section].reuseIdentifier
        print("identifier \(identifier)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CardDetailTableViewCell else {
            return UITableViewCell()
        }
        
        switch detailSections[indexPath.section] {
        case .nameCell:
            cell.mainLabel?.text = cardDescriptor?.name
        case .descriptionCell:
            cell.mainLabel?.text = cardDescriptor?.description
        case .endDetailsCell:
            cell.mainLabel?.text = cardDescriptor?.endDescription
        case .outputsCell:
            cell.mainLabel?.text = cardDescriptor?.yieldDescription
        default:
            return cell
        }
        
        cell.setupCell(cardDescriptor: cardDescriptor!)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch detailSections[indexPath.section].rawValue {
        case CellIdentifiers.nameCell.rawValue:
            return 30.0
        case CellIdentifiers.descriptionCell.rawValue, CellIdentifiers.endDetailsCell.rawValue, CellIdentifiers.outputsCell.rawValue:
            return 26.0
        case CellIdentifiers.location2DInput.rawValue:
            return 800.0
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.header.reuseIdentifier) as? CardDetailHeaderView
        let labelText = detailSections[section].headerName()
        header?.label?.text = labelText.uppercased()
        
        if section == CellIdentifiers.nameCell.rawValue {
            header?.endsLabel?.isHidden = false
            header?.ends = (cardDescriptor?.ends)!
        }
        
        return header
    }
    
    // MARK: - IBActions
    
    @IBAction func close() {
        self.dismiss(animated: true) {
            print("CardDetailNavController dismissed")
        }
    }
    
    @IBAction func removeCard() {
        print("REMOVE CARD!")
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */


}
