//
//  LibraryViewController.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    public struct NotificationName {
        static let displayLogsView = NSNotification.Name("DisplayLogsView")
        static let displayCardsView = NSNotification.Name("DisplayCardsView")
    }
    
    enum CellType: Int {
        case cards
        case logs
        
        var storyboardID: String {
            switch self {
            case .cards:
                return "Cards"
            case .logs:
                return "Logs"
            }
        }
    }
    
    var segmentControl: UISegmentedControl?
    @IBOutlet weak var currContainedView: UIView!
    var currentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryViewController.displayLogsView), name: NotificationName.displayLogsView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryViewController.displayCardsView), name: NotificationName.displayCardsView, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        displayCardsView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NotificationName.displayLogsView, object: nil)
        NotificationCenter.default.removeObserver(self, name: NotificationName.displayCardsView, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSegmentedControl() {
        // Do any additional setup after loading the view.
        let items = ["Cards", "Logs"]
        let widthPerItem = 280/items.count
        
        segmentControl = UISegmentedControl(items: items)
        
        for index in 0..<items.count {
            segmentControl?.setWidth(CGFloat(widthPerItem), forSegmentAt: index)
        }
        
        if let segmentControl = segmentControl {
            self.navigationItem.titleView = segmentControl
        }
        
        //setup the segmented control to show first and cardsVC by default
        segmentControl?.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
    }
    
    func createContainedView(storyboardID: String) {
        guard let currViewController = self.storyboard?.instantiateViewController(withIdentifier: storyboardID) else { return }
        
        currViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(currViewController)
        currContainedView.addSubview(currViewController.view)
        
        NSLayoutConstraint.activate([
            currViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            currViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            currViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            currViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            ])
        
        currentViewController = currViewController
    }
    
    func updateView(newView: CellType) {
        if let currViewController = currentViewController {
            //something exists here so remove it
            currViewController.willMove(toParentViewController: nil)
            currViewController.view.removeFromSuperview()
            currViewController.removeFromParentViewController()
        }
        
        createContainedView(storyboardID: newView.storyboardID)
    }
    
    func selectionDidChange(_ sender: UISegmentedControl) {
        if let libs = CellType(rawValue: sender.selectedSegmentIndex) {
            updateView(newView: libs)
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Notifcation Handlers
    func displayLogsView() {
        segmentControl?.selectedSegmentIndex = CellType.logs.rawValue
        updateView(newView: .logs)
    }
    
    func displayCardsView() {
        segmentControl?.selectedSegmentIndex = CellType.cards.rawValue
        updateView(newView: .cards)
    }
}
