//
//  CanvasViewController.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var toolBar: CanvasToolBar!
    @IBOutlet weak var tableView: UITableView!
    var footerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    
    func setupTableView() {
        //setup any tableview stuff here
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .cornflowerBlue
        registerNotifications()
        
        
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CanvasViewController.statusBarDidChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as HandTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 40.0))
        footerView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        let insertHandButton = UIButton(type: .roundedRect)
        insertHandButton.frame = CGRect(x: (tableView.frame.size.width - 150.0)/2, y: 0.0, width: 150.0, height: 60.0)
        insertHandButton.autoresizingMask = UIViewAutoresizing.flexibleWidth
        insertHandButton.setTitle(NSLocalizedString("ADD_STEP_TITLE", comment: "Add Step Title"), for: .normal)
        insertHandButton.tag = 0
        footerView.addSubview(insertHandButton)
        NSLayoutConstraint.activate([
            footerView.centerXAnchor.constraint(equalTo: insertHandButton.centerXAnchor),
            footerView.topAnchor.constraint(equalTo: insertHandButton.bottomAnchor, constant: 0)
            ])
        self.footerView = footerView
        
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60.0
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

extension CanvasViewController {
    
    func statusBarDidChange(note: Notification) {
        
        tableView.setNeedsUpdateConstraints()
        if let footerview = footerView {
            print("TABLE Width \(tableView.frame.size.width)")
//            if let insertButton = footerview.viewWithTag(0) {
//                insertButton.frame = CGRect(x: (tableView.frame.size.width - 150.0)/2, y: 0.0, width: 150.0, height: 40.0)
//            }
            footerview.setNeedsUpdateConstraints()
        }
    }
    
}
