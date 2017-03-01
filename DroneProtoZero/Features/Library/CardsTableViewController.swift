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
    
    private var allCards: [String: [ActionCardDescriptor]]?
    private var cardKeys: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        
        allCards = DroneCardKit.allCardsGrouped()
        if let cards = allCards {
            cardKeys = Array(cards.keys)
        }
        
        print("allCards \(allCards)\n\n\n")
        print("all keys \(cardKeys)")
        
        
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
        guard let count = allCards?.count else {
            return 0
        }
        return count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //allCards is a dictionary and as such we cannot reference elements via section unless
        //we get the array of keys in the dictionary.  as both are optional, allCards and cardKeys
        //are wrapped in guard statement
        guard let cards = allCards, let keys = cardKeys else {
            return 0
        }

        let key = keys[section]
        guard let count = cards[key]?.count else {
            return 0
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CardTableViewCell
        guard let cards = allCards, let keys = cardKeys else {
            return cell
        }
        cell.label?.text = cards[keys[indexPath.section]]?[indexPath.row].name
        return cell
    }
 
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let title = cardKeys?[section] else {
            return ""
        }
        return title
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
