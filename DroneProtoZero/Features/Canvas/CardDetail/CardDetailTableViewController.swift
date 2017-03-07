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
            print("DESCRIPTOR endDescription \(descriptor.endDescription)")
            print("DESCRIPTOR yieldDescription \(descriptor.yieldDescription)")
            if descriptor.endDescription != "" {
                detailSections.append(.endDetailsCell)
            }
            if descriptor.yieldDescription != "" {
                detailSections.append(.outputsCell)
            }
            
            for input in descriptor.inputSlots {
                print("INPUT \(input) ... \(input.descriptor.name)")
                switch input.descriptor.name {
                case "Coordinate 2D":
                    detailSections.append(.location2DInput)
                    break
                case "Altitude", "Speed", "Distance", "Radius", "AngularSpeed":
                    detailSections.append(.standardInputCell)
                    break
                case "MovementDirection":
                    print("input on binary choice \(input.descriptor)")
                    detailSections.append(.binaryChoiceCell)
                default:
                    break
                }
            }
            
            print("DETAIL SECTIONS \(detailSections)")
        }
    }
    
    private var detailSections: [CellIdentifiers] = [.nameCell, .descriptionCell]
    
    private enum CellIdentifiers: Int {
        case nameCell
        case descriptionCell
        case endDetailsCell
        case outputsCell
        case location2DInput
        case standardInputCell
        case binaryChoiceCell
        case header
        
        var reuseIdentifier: String {
            switch self {
            case .nameCell:
                return "NameCell"
            case .descriptionCell, .endDetailsCell, .outputsCell:
                return "DescriptionCell"
            case .location2DInput:
                return "Location2DInputCell"
            case .standardInputCell:
                return "StandardInputCell"
            case .binaryChoiceCell:
                return "BinaryChoiceCell"
            case .header:
                return "Header"
            }            
        }
        
        func headerName(type: String?) -> String {
            switch self {
            case .nameCell:
                return "Card Name"
            case .descriptionCell:
                return "Description"
            case .endDetailsCell:
                return "End Details"
            case .outputsCell:
                return "Outputs"
            case .standardInputCell, .location2DInput, .binaryChoiceCell:
                guard let inputType = type else {
                    return "Input"
                }
                return "Input: \(inputType)"
            case .header:
                return ""
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInset = UIEdgeInsets(top: 40.0, left: 0.0, bottom: 0.0, right: 0.0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let numSections = detailSections.count
        print("numSections \(numSections)")
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String = detailSections[indexPath.section].reuseIdentifier
        
        print("section \(indexPath.section)   reuse id \(identifier)")
        
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
        case .standardInputCell, .binaryChoiceCell:
            let index = indexPath.section - (detailSections.count - (cardDescriptor?.inputSlots.count)!)
            if let inputSlot = cardDescriptor?.inputSlots[index] {
                //TODO: need unit from somewhere in data
                cell.mainLabel?.text = "\(inputSlot.name) NEED UNIT"
            }
        default:
            return cell
        }
        
        cell.setupCell(cardDescriptor: cardDescriptor!)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.header.reuseIdentifier) as? CardDetailHeaderView
        var headerType: String?
        if detailSections[section] == .location2DInput ||
            detailSections[section] == .standardInputCell ||
            detailSections[section] == .binaryChoiceCell {
            
            let index = section - (detailSections.count - (cardDescriptor?.inputSlots.count)!)
            if let inputSlot = cardDescriptor?.inputSlots[index] {
                print("section \(section) ----   input slot to use for header \(inputSlot)")
                headerType = inputSlot.name
                header?.optional = inputSlot.isOptional
                
            }
        }
        let labelText = detailSections[section].headerName(type: headerType)
        header?.label?.text = labelText.uppercased()
        
        if section == CellIdentifiers.nameCell.rawValue {
            header?.endsLabel?.isHidden = false
            header?.ends = (cardDescriptor?.ends)!
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch detailSections[indexPath.section].rawValue {
        case CellIdentifiers.nameCell.rawValue:
            return 30.0
        case CellIdentifiers.descriptionCell.rawValue, CellIdentifiers.endDetailsCell.rawValue, CellIdentifiers.outputsCell.rawValue:
            return 26.0
        case CellIdentifiers.location2DInput.rawValue:
            return 774.0
        case CellIdentifiers.standardInputCell.rawValue:
            return 66.0
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == CellIdentifiers.endDetailsCell.rawValue || section == CellIdentifiers.outputsCell.rawValue {
            return 40.0
        }
        return 20.0
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
