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
    
    var cardDescriptor: ActionCardDescriptor?
    
    private enum CellIdentifiers: Int {
        case NameCell
        case DescriptionCell
        case EndDetailsCell
        case OutputsCell
        
        var reuseIdentifier: String {
            switch self {
            case .NameCell:
                return "NameCell"
            case .DescriptionCell, .EndDetailsCell, .OutputsCell:
                return "DescriptionCell"
            }            
        }
        
        func headerName() -> String {
            switch self {
            case .NameCell:
                return "Card Name"
            case .DescriptionCell:
                return "Description"
            case .EndDetailsCell:
                return "End Details"
            case .OutputsCell:
                return "Outputs"
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

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
        var numSections = 2
        guard let descriptor = self.cardDescriptor else {
            return numSections
        }
        if descriptor.endDescription != "" {
            numSections += 1
        }
        if descriptor.yields.count > 0 {
            numSections += 1
        }
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String = (CellIdentifiers(rawValue: indexPath.section)?.reuseIdentifier)!
        print("identifier \(identifier)")
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return CellIdentifiers(rawValue: section)?.headerName()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case CellIdentifiers.NameCell.rawValue:
            return 30.0
        case CellIdentifiers.DescriptionCell.rawValue, CellIdentifiers.EndDetailsCell.rawValue, CellIdentifiers.OutputsCell.rawValue:
            return 26.0
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return UITableViewAutomaticDimension
        }
        return 15.0
    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 2.0
//    }
    
    
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
