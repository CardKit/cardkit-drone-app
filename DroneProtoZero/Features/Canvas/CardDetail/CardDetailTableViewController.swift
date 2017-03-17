//
//  CardDetailTableViewController.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/2/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class CardDetailTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, PathInputCellDelegate {
    
    
    var card: ActionCard? {
        didSet {

            guard let descriptor = card?.descriptor else { return }
            cardDescriptor = descriptor

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
                case "Coordinate 3D":
                    detailSections.append(.location3DInput)
                case "Path":
                    detailSections.append(.pathInput)                    
                case "Altitude", "Speed", "Distance", "Radius", "AngularSpeed", "Aspect Ratio":
                    detailSections.append(.standardInputCell)
                case "Boolean", "RotationDirection":
                    detailSections.append(.binaryChoiceCell)
                case "Quality":
                    detailSections.append(.multipleChoiceCell)
                default:
                    continue
                }
            }
            
            print("DETAIL SECTIONS \(detailSections)")
        }
    }
    var cardDescriptor: ActionCardDescriptor?
    
    private var detailSections: [CellIdentifiers] = [.nameCell, .descriptionCell]
    
    private enum CellIdentifiers: Int {
        case nameCell
        case descriptionCell
        case endDetailsCell
        case outputsCell
        case location2DInput
        case location3DInput
        case pathInput
        case standardInputCell
        case binaryChoiceCell
        case multipleChoiceCell
        
        var reuseIdentifier: String {
            switch self {
            case .nameCell:
                return "NameCell"
            case .descriptionCell, .endDetailsCell, .outputsCell:
                return "DescriptionCell"
            case .location2DInput:
                return "Location2DInputCell"
            case .location3DInput:
                return "Location3DInputCell"
            case .pathInput:
                return "PathInputCell"
            case .standardInputCell:
                return "StandardInputCell"
            case .binaryChoiceCell:
                return "BinaryChoiceCell"
            case .multipleChoiceCell:
                return "MultipleChoiceCell"
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
            case .standardInputCell, .location2DInput, .location3DInput, .pathInput, .binaryChoiceCell, .multipleChoiceCell:
                guard let inputType = type else {
                    return "Input"
                }
                return "Input: \(inputType)"
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInset = UIEdgeInsets(top: 40.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.contentOffset = CGPoint.zero
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let numSections = detailSections.count        
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String = detailSections[indexPath.section].reuseIdentifier
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CardDetailTableViewCell else {
            return UITableViewCell()
        }
        
        switch detailSections[indexPath.section] {
        case .nameCell:
            cell.mainLabel?.text = cardDescriptor?.name
        case .descriptionCell:
            cell.mainLabel?.text = cardDescriptor?.assetCatalog.textualDescription
        case .endDetailsCell:
            cell.mainLabel?.text = cardDescriptor?.endDescription
        case .outputsCell:
            cell.mainLabel?.text = cardDescriptor?.yieldDescription
        case .standardInputCell:
            let index = inputIndex(for: indexPath.section)
            if let inputSlot = cardDescriptor?.inputSlots[index] {
                //TODO: need unit from somewhere in data
                cell.mainLabel?.text = "\(inputSlot.descriptor.inputDescription)"
                
            }
        case .binaryChoiceCell:
            let index = inputIndex(for: indexPath.section)
            if let inputSlot = cardDescriptor?.inputSlots[index] {
                cell.mainLabel?.text = "\(inputSlot.name)"
                if let binaryChoiceCell = cell as? BinaryChoiceCell,
                    let segments = binaryChoiceCell.segControl?.numberOfSegments {
                    for i in 0...segments-1 {
                        binaryChoiceCell.segControl?.setTitle("Temp Choice \(i)", forSegmentAt: i)
                    }
                }
            }
        case .multipleChoiceCell:

            guard let multipleChoiceCell = cell as? MultipleChoiceCell else {
                return cell
            }
            
            multipleChoiceCell.section = indexPath.section
            //TODO: these need to come from somewhere
            let choices = ["None", "Normal", "Fine", "Excellent"]
            //TODO: set selection based on data in card
            if let selectionIndex = multipleChoiceCell.selection {
                multipleChoiceCell.button?.setTitle(choices[selectionIndex], for: .normal)
            }
            if let inputSlot = cardDescriptor?.inputSlots[inputIndex(for: indexPath.section)] {
                multipleChoiceCell.mainLabel?.text = inputSlot.descriptor.inputDescription
            }
        case .pathInput:
            guard let pathInputCell = cell as? PathInputCell else {
                return cell
            }
            pathInputCell.delegate = self
            
        default:
            return cell
        }
        
        cell.setupCell(cardDescriptor: cardDescriptor!)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header =  Bundle.main.loadNibNamed("CardDetailHeader", owner: nil, options: nil)?.first as? CardDetailHeaderView else {
            return nil
        }

        var headerType: String?
        
        switch detailSections[section] {
        case .location2DInput, .standardInputCell, .binaryChoiceCell, .multipleChoiceCell:
            let index = inputIndex(for: section)
            if let inputSlot = cardDescriptor?.inputSlots[index] {
                headerType = inputSlot.name
                header.optional = inputSlot.isOptional
            }
        case .nameCell:
            if let descriptor = cardDescriptor {
                header.endsLabel?.isHidden = false
                header.ends = descriptor.ends
            }
        default:
            break
        }
        
        let labelText = detailSections[section].headerName(type: headerType)
        header.label?.text = labelText.uppercased()
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
 
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //TODO: need to figure out how to add 40px between end cell or output cell, depending on what there is.
//        if section == CellIdentifiers.endDetailsCell.rawValue || section == CellIdentifiers.outputsCell.rawValue {
//            return 40.0
//        }
        return 20.0
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        
        guard let multipleChoiceOptions = popoverPresentationController.presentedViewController as? MultipleChoiceOptions,
            let multipleChoiceCell = popoverPresentationController.sourceView?.superview?.superview?.superview as? MultipleChoiceCell else {
            return true
        }
        
        let selectedPaths = multipleChoiceOptions.tableView.indexPathsForSelectedRows
        for path in selectedPaths! {
            multipleChoiceCell.selection = path.row
            //TODO: this needs to be set in the card when selection is made
        }
        
        return true
    }
    
    // MARK: - PathInputCellDelegate
    
    func cellSizeUpdated(cell: PathInputCell) {
        //need the cell height to be recalculated but don't wish for the cell to be reloaded as that causes the 
        //contained map to also be reloaded
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Instance methods
    
    func inputIndex(for section: Int) -> Int {
        return section - (detailSections.count - (cardDescriptor?.inputSlots.count)!)
    }
    
    // MARK: - IBActions
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeCard() {
        print("REMOVE CARD!")
    }
    
    @IBAction func displayMultipleChoiceOptions(sender: UIButton) {
        guard let options = UIStoryboard(name: "CardDetail", bundle: nil).instantiateViewController(withIdentifier: "MultipleChoiceOptions") as? MultipleChoiceOptions else {
            return
        }
        
        let inputSlot = cardDescriptor?.inputSlots[inputIndex(for: sender.tag)]
        //TODO: these need to come from somewhere
        let choices = ["None", "Normal", "Fine", "Excellent"]
        options.optionsTitle = inputSlot?.descriptor.name
        options.options = choices
        options.modalPresentationStyle = .popover
        options.preferredContentSize = options.popoverSize
        let popover: UIPopoverPresentationController = options.popoverPresentationController!        
        popover.sourceView = sender
        popover.delegate = self
        
        self.present(options, animated: true, completion: nil)
        
    }
}
