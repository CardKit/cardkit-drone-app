//
//  CardDetailTableViewController.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/2/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

protocol CardDetailDelegate: class {
    func removeCardWasPressed(card: ActionCard)
}

class CardDetailTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
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
                    break
                case "Altitude", "Speed", "Distance", "Radius", "AngularSpeed", "Aspect Ratio":
                    detailSections.append(.standardInputCell)
                    break
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
    weak var delegate: CardDetailDelegate?
    
    private var detailSections: [CellIdentifiers] = [.nameCell, .descriptionCell]
    
    private enum CellIdentifiers: Int {
        case nameCell
        case descriptionCell
        case endDetailsCell
        case outputsCell
        case location2DInput
        case standardInputCell
        case binaryChoiceCell
        case multipleChoiceCell
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
            case .multipleChoiceCell:
                return "MultipleChoiceCell"
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
            case .standardInputCell, .location2DInput, .binaryChoiceCell, .multipleChoiceCell:
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
                print("set text on button to \(choices[selectionIndex])")
                multipleChoiceCell.button?.setTitle(choices[selectionIndex], for: .normal)
            }
            if let inputSlot = cardDescriptor?.inputSlots[inputIndex(for: indexPath.section)] {
                multipleChoiceCell.mainLabel?.text = inputSlot.descriptor.inputDescription
            }
            
        default:
            return cell
        }
        
        cell.setupCell(cardDescriptor: cardDescriptor!)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.header.reuseIdentifier) as? CardDetailHeaderView else {
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
        //TODO: need to figure out how to add 40px between end cell or output cell, depending on what there is.
//        if section == CellIdentifiers.endDetailsCell.rawValue || section == CellIdentifiers.outputsCell.rawValue {
//            return 40.0
//        }
        return 20.0
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        print("popover osurce view \(popoverPresentationController.sourceView?.superview?.superview?.superview)")
        
        guard let multipleChoiceOptions = popoverPresentationController.presentedViewController as? MultipleChoiceOptions,
            let multipleChoiceCell = popoverPresentationController.sourceView?.superview?.superview?.superview as? MultipleChoiceCell else {
            return true
        }
        print("multiple choice cell popover!!! \(multipleChoiceCell)")
        let selectedPaths = multipleChoiceOptions.tableView.indexPathsForSelectedRows
        for path in selectedPaths! {
            multipleChoiceCell.selection = path.row
            //TODO: this needs to be set in the card when selection is made
        }
        
        return true
    }
    
    // MARK: - Instance methods
    
    func inputIndex(for section: Int) -> Int {
        return section - (detailSections.count - (cardDescriptor?.inputSlots.count)!)
    }
    
    // MARK: - IBActions
    
    @IBAction func close() {
        self.dismiss(animated: true) {
            print("CardDetailNavController dismissed")
        }
    }
    
    @IBAction func removeCard() {
        guard let card = card else { return }
        delegate?.removeCardWasPressed(card: card)
    }
    
    @IBAction func displayMultipleChoiceOptions(sender: UIButton) {
        guard let options = UIStoryboard(name: "CardDetail", bundle: nil).instantiateViewController(withIdentifier: "MultipleChoiceOptions") as? MultipleChoiceOptions else {
            return
        }
        
        let inputSlot = cardDescriptor?.inputSlots[inputIndex(for: sender.tag)]
        print("inputSlot \(inputSlot)")
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
