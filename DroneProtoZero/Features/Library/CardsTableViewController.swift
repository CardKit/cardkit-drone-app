//
//  CardsTableViewController.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit
import DroneCardKit


class CardsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

   override func numberOfSections(in tableView: UITableView) -> Int {
        return DroneCardDescriptors.sharedInstance.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = DroneCardDescriptors.sharedInstance.descriptorsAtGroupIndex(index: section)?.count else {
            return 0
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CardTableViewCell
        if let cardDescriptor = DroneCardDescriptors.sharedInstance.descriptorAtIndexPath(indexPath: indexPath) {
            cell.cardDescriptor = cardDescriptor
            cell.label?.text = cardDescriptor.name
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {        
        return DroneCardDescriptors.sharedInstance.keyAtIndex(index: section)
    }
}
