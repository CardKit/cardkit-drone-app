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
        tableView.tableFooterView = createTableFooter()
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
        let index = [currentCount]
        tableView.insertSections(IndexSet(index), with: UITableViewRowAnimation.bottom)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if viewModel.sectionType(for: section) == CanvasSection.steps {
            return createStepHeader(section: section)
        }
        return UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(viewModel.headerHeight(section: section))
    }
    
    func createStepHeader(section: Int) -> UIView {
        guard let views = Bundle.main.loadNibNamed("CanvasStepHeaderView", owner: self, options: nil),
            let headerView = views[0] as? CanvasStepHeaderView else { return UIView(frame: CGRect.zero) }
        headerView.setupHeader(section: section, delegate: self)
        return headerView
    }
    
    func createTableFooter() -> UIView {
        guard let views = Bundle.main.loadNibNamed("AddStepFooterView", owner: self, options: nil),
            let footerView = views[0] as? AddStepFooterView else { return UIView(frame: CGRect.zero) }
        footerView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        footerView.addStep.addTarget(self, action: #selector(CanvasViewController.addNewStep(sender:)), for: .touchUpInside)
        return footerView
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

extension CanvasViewController: CanvasStepHeaderDelegate {
    
    func removeStepSection(for section: Int) {
        viewModel.sectionCount -= 1
        tableView.beginUpdates()
        let index = [section]
        tableView.deleteSections(IndexSet(index), with: UITableViewRowAnimation.bottom)
        if section < viewModel.sectionCount {
            tableView.reloadSections(viewModel.createIndexSet(section: section), with: .automatic)
        }
        tableView.endUpdates()
    }
}
