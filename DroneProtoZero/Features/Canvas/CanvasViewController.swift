//
//  CanvasViewController.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit
import DroneCardKit

protocol Hoverable {
    
    func addItemToView<T>(item: T, position: CGPoint)
    func showHovering(position: CGPoint)
    func cancelHovering()
    func isViewHovering(view: UIView, touchPoint: CGPoint) -> Bool
    var hoverableView: UIView { get }
    
}

class CanvasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: CanvasViewModel = CanvasViewModel()
    var hoveredCellID: Int?
    
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
        guard let sectionType = viewModel.sectionType(for: indexPath.section) else { return UITableViewCell() }
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
            if let handCell = cell as? HandTableViewCell {
                handCell.setupHand(sectionID: indexPath.section, delegate: self)
            }
            break
        }
        cell.layer.cornerRadius = 11.0
        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("selected \(indexPath)")
//        if indexPath.section > 1 {
//            switch indexPath.section {
//            case 2:
//                displayCardDetail(cardDescriptor: DroneCardKit.Action.Movement.Location.FlyTo)
//            case 3:
//                displayCardDetail(cardDescriptor: DroneCardKit.Action.Movement.Simple.FlyForward)
//            case 4:
//                displayCardDetail(cardDescriptor: DroneCardKit.Action.Movement.Location.Circle)
//            default:
//                displayCardDetail(cardDescriptor: DroneCardKit.Action.Movement.Location.FlyTo)
//            }
//        }
//    }
    
    // MARK: - Card details
    
    func displayCardDetail(card: ActionCard) {
        guard let cardDetailNavController = UIStoryboard(name: "CardDetail", bundle: nil).instantiateInitialViewController() as? UINavigationController else {
            print("no card detail")
            return
        }
        cardDetailNavController.modalPresentationStyle = .pageSheet
        print("table vc \(cardDetailNavController.topViewController)")
        
        if let cardDetailTableViewController = cardDetailNavController.topViewController as? CardDetailTableViewController {
            print("Canvas vc sets cardDescriptor")
            cardDetailTableViewController.card = card
        }
        
        self.parent?.present(cardDetailNavController, animated: true) {
            print("present card detail")
        }
    }

    // MARK: - Add card
    
    func addCardToHand(descriptor: ActionCardDescriptor, position: CGPoint) {
        //indexPathForRowAtPoint:point
        guard let indexPath = tableView.indexPathForRow(at: position) else { return }
        guard let handCell = tableView.cellForRow(at: indexPath) as? HandTableViewCell else { return }
        print("CARD DESCRIPTOR: \(descriptor) added to this section \(indexPath.section)")
        
        do {
            try viewModel.addCard(cardDescriptor: descriptor, toHand: indexPath.section)
            handCell.addCard(card: descriptor)
        } catch {
            print("I think were should be showing an error here, as I couldnt add a card")
        }
    }
    
    func addNewStep(sender: UIButton) {
        let currentCount = viewModel.sectionCount
        let _ = viewModel.addHand()
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
        if section < CanvasSection.steps.rawValue {
            //print("section \(section)")
            return 1.0
        }
        return 50.0
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
        //how do i get the identifier from the section?
        let _ = viewModel.removeHand(sectionID: section)
        tableView.beginUpdates()
        let index = [section]
        tableView.deleteSections(IndexSet(index), with: UITableViewRowAnimation.bottom)
        if section < viewModel.sectionCount {
            tableView.reloadSections(viewModel.createIndexSet(section: section), with: .automatic)
        }
        tableView.endUpdates()
    }
}

extension CanvasViewController: Hoverable {
    
    internal var hoverableView: UIView {
        return self.view
    }
    
    func addItemToView<T>(item: T, position: CGPoint) {
        cancelHovering()
        if let descriptor = item as? ActionCardDescriptor {
             let positionWithOffset = addOffsetTo(position: position)
            addCardToHand(descriptor: descriptor, position: positionWithOffset)
        }
    }
    
    func isViewHovering(view: UIView, touchPoint: CGPoint) -> Bool {
        //to convert a point from one view to the other both views needs to be inside a common one (hence view.superview, their both in splitview)
        //then you can convert point from where the persons' finger is (touchpoint) to tableview
        guard let convertedPoint = view.superview?.convert(touchPoint, to: tableView) else { return false }
        //create a rect so you can use intersects, but you really only care about the point
        let convertedFrame = CGRect(x: convertedPoint.x, y: convertedPoint.y, width: 0, height: 0)
        //create a rect from tableview that uses the WHOLE tableview i.e. contentSize
        let tableContentFrame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.contentSize.width, height: tableView.contentSize.height)
        //run the magic
        return tableContentFrame.intersects(convertedFrame)
    }
    
    func cancelHovering() {
        if let hoveredCellID = hoveredCellID,
            let oldHoverCell = tableView.cellForRow(at: IndexPath(row: 0, section: hoveredCellID)) as? HandTableViewCell {
            oldHoverCell.showHovering(isHovering: false)
        }
    }
    
    func showHovering(position: CGPoint) {
        cancelHovering()
        let positionWithOffset = addOffsetTo(position: position)
        guard let indexPath = tableView.indexPathForRow(at: positionWithOffset),
                    let handCell = tableView.cellForRow(at: indexPath) as? HandTableViewCell else { return }
        handCell.showHovering(isHovering: true)
        hoveredCellID = indexPath.section
    }
    
    func addOffsetTo(position: CGPoint) -> CGPoint {
        let offsetY = tableView.contentOffset.y
        return CGPoint(x: position.x, y: position.y + offsetY)
    }
    
}

extension CanvasViewController: CardViewDelegate {
    
    func cardViewWasSelected(handID: Int, cardID: Int) {
        guard let card = viewModel.getCard(forHand: handID, cardID: cardID),
            let actionCard = card as? ActionCard else { return }
             displayCardDetail(card: actionCard)
    }
}
