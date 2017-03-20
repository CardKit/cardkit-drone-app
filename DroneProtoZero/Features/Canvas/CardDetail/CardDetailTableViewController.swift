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

class CardDetailTableViewController: UITableViewController, PathInputCellDelegate {
    
    var card: ActionCard! {
        didSet {
            
            let descriptor = cardDescriptor
            
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
                case "Altitude", "Speed", "Distance", "Radius", "AngularSpeed", "Duration":
                    detailSections.append(.standardInputCell)
                case "Boolean", "RotationDirection":
                    detailSections.append(.binaryChoiceCell)
                case "Quality", "Aspect Ratio":
                    detailSections.append(.multipleChoiceCell)
                default:
                    continue
                }
            }
            
            print("DETAIL SECTIONS \(detailSections)")
        }
    }
    var cardDescriptor: ActionCardDescriptor {
        return card.descriptor
    }

	weak var delegate: CardDetailDelegate?
    
    private var detailSections: [CardDetailTypes] = [.nameCell, .descriptionCell]
    
    public enum CardDetailTypes: Int {
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
        tableView.estimatedRowHeight = 600.0
        
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
        
        let type: CardDetailTypes = detailSections[indexPath.section]
        let identifier: String = type.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        
        
        if var inputCell = cell as? CardDetailInputCell {
            inputCell.type = type
            guard let inputSlotIndex = inputIndex(for: indexPath.section) else {
                return cell
            }
            let descriptor = card.descriptor
            inputCell.inputSlot = descriptor.inputSlots[inputSlotIndex]
            inputCell.setupCell(card: card, indexPath: indexPath)
            
            if let pathInputCell = inputCell as? PathInputCell {
                pathInputCell.delegate = self
            }
        } else if var detailCell = cell as? CardDetailCell {
            detailCell.type = type
            detailCell.setupCell(card: card, indexPath: indexPath)
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header =  Bundle.main.loadNibNamed("CardDetailHeader", owner: nil, options: nil)?.first as? CardDetailHeaderView else {
            return nil
        }

        var headerType: String?
        
        switch detailSections[section] {
        case .location2DInput, .standardInputCell, .binaryChoiceCell, .multipleChoiceCell:
            if let index = inputIndex(for: section) {
                let inputSlot = cardDescriptor.inputSlots[index]
                headerType = inputSlot.name
                header.optional = inputSlot.isOptional
            }
        case .nameCell:
            header.endsLabel?.isHidden = false
            header.ends = card.descriptor.ends
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

    // MARK: - PathInputCellDelegate
    
    func cellSizeUpdated(cell: PathInputCell) {
        //need the cell height to be recalculated but don't wish for the cell to be reloaded as that causes the 
        //contained map to also be reloaded
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Instance methods
    
    func inputIndex(for section: Int) -> Int? {
        return section - (detailSections.count - cardDescriptor.inputSlots.count)
    }
    
    // MARK: - IBActions
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeCard() {
        guard let card = card else { return }
        delegate?.removeCardWasPressed(card: card)
    }
    
    @IBAction func displayMultipleChoiceOptions(sender: UIButton) {
        
        guard let multipleChoiceCell = sender.superview?.superview?.superview as? MultipleChoiceCell,
            let options = UIStoryboard(name: "CardDetail", bundle: nil).instantiateViewController(withIdentifier: "MultipleChoicePopover") as? MultipleChoicePopover
        else { return }
        
        options.delegate = multipleChoiceCell
        options.optionsTitle = multipleChoiceCell.inputSlot?.descriptor.name
        options.options = multipleChoiceCell.choices
        options.selectedIndex = multipleChoiceCell.selection
        options.modalPresentationStyle = .popover
        options.preferredContentSize = options.popoverSize

        if let popover: UIPopoverPresentationController = options.popoverPresentationController {
            popover.sourceView = sender
            self.present(options, animated: true, completion: nil)
        }
    }
}
