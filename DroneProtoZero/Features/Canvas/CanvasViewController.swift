//
//  CanvasViewController.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class CanvasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: CanvasViewModel = CanvasViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        self.view.backgroundColor = .athensGray
        //setup any tableview stuff here
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.white
        self.view.backgroundColor = .athensGray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.cellHeight(for: indexPath))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let sectionType = CanvasSection(rawValue: indexPath.section) else { return UITableViewCell() }
        let cell: UITableViewCell
        switch  sectionType {
        case .status:
            cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as DroneStatusCell
            break
        case .hardware:
            cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as AvailableHardwareCell
            break
        default:
            cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as HandTableViewCell
            break
        }
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // MARK: - Add card
    
    func addCardToHand(descriptor: ActionCardDescriptor, position: CGPoint) {
        //indexPathForRowAtPoint:point
        guard let indexPath = tableView.indexPathForRow(at: position) else { return }
        
        print("CARD DESCRIPTOR: \(descriptor) added to this section \(indexPath.section)")
    }
    
    func addNewStep(sender: UIButton) {
         let currentCount = viewModel.sectionCount
         viewModel.sectionCount += 1
        tableView.beginUpdates()
        let index = [currentCount-1]
        tableView.insertSections(IndexSet(index), with: UITableViewRowAnimation.bottom)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == viewModel.sectionCount-1 {
            //TODO: need to add in header for steps section
            return UIView(frame: CGRect.zero)
        }
        return UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < CanvasSection.steps.rawValue {
            print("section \(section)")
            return 1.0
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == viewModel.sectionCount-1 {
            let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 40.0))
            footerView.autoresizingMask = UIViewAutoresizing.flexibleWidth
            let insertHandButton = UIButton(type: .roundedRect)
            insertHandButton.frame = CGRect(x: (tableView.frame.size.width - 150.0)/2, y: 0.0, width: 150.0, height: 60.0)
            insertHandButton.addTarget(self, action: #selector(CanvasViewController.addNewStep), for: .touchUpInside)
            insertHandButton.autoresizingMask = UIViewAutoresizing.flexibleWidth
            insertHandButton.setTitle(NSLocalizedString("ADD_STEP_TITLE", comment: "Add Step Title"), for: .normal)
            insertHandButton.tag = 0
            footerView.addSubview(insertHandButton)
            
            return footerView
        }
        return UIView(frame: CGRect.zero)
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == viewModel.sectionCount-1 {
            return 60.0
        }
        return 0.0
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
