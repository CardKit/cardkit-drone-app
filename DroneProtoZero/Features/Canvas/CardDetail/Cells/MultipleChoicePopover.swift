//
//  MultipleChoicePopover.swift
//  DroneProtoZero
//
//  Created by Kristina M Brimijoin on 3/10/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class MultipleChoicePopover: UITableViewController {
    
    let popoverSize: CGSize = CGSize(width: 320.0, height: 240.0)
    
    var optionsTitle: String?
    var options: [String]?

    private enum CellIdentifiers: Int {
        case header
        case cell
        
        var reuseIdentifier: String {
            switch self {
            case .header:
                return "MultipleChoiceHeaderCell"
            case .cell:
                return "MultipleChoiceCell"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
        tableView.tableFooterView = UIView(frame: .zero)        
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let choiceOptions = options else {
            return 0
        }
        return choiceOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cell.reuseIdentifier, for: indexPath)
        
        guard let text = options?[indexPath.row] else {
            return cell
        }
        cell.textLabel?.text = text

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.header.reuseIdentifier) else {
            return nil
        }
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: header.frame.size.height - 1.0, width: header.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.tableViewSeparatorGray.cgColor
        header.layer.addSublayer(bottomBorder)
        
        if let title = self.optionsTitle {
            header.textLabel?.text = title
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
            for path in indexPathsForSelectedRows {
                if let cell = tableView.cellForRow(at: path) {
                    cell.isSelected = false
                }
                
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = true
        }        
    }

}

class MultipleChoiceOptionCell: UITableViewCell, Reusable {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.textLabel?.textColor = UIColor.tableViewDefaultBlue
                self.accessoryType = .checkmark
            } else {
                self.textLabel?.textColor = UIColor.darkText
                self.accessoryType = .none
            }
        }
    }
}
