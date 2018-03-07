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

import UIKit

protocol MultipleChoicePopoverDelegate: class {
    func didMakeSelection(selection: Int)
}

class MultipleChoicePopover: UITableViewController {
    
    
    let popoverSize: CGSize = CGSize(width: 320.0, height: 240.0)
    
    weak var delegate: MultipleChoicePopoverDelegate?
    var optionsTitle: String?
    var options: [String]?
    var selectedIndex: Int = 0

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
        tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .top)
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
            if let delegate = self.delegate {
                delegate.didMakeSelection(selection: indexPath.row)
            }
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
