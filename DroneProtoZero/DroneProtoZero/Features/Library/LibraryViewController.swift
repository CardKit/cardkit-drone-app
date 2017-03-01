//
//  LibraryViewController.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    
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
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var currContainedView: UIView!
    var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        //setup the segmented control to show first and cardsVC by default
        segmentControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        createContainedView(storyboardID: CellType.cards.storyboardID)
    }
    
    func createContainedView(storyboardID: String) {
        print("CONSTRAINTS \(view.constraints)\n\n\n")
        if let currViewController = self.storyboard?.instantiateViewController(withIdentifier: storyboardID) {
            currViewController.view.translatesAutoresizingMaskIntoConstraints = false
            self.addChildViewController(currViewController)
            currViewController.view.layoutIfNeeded()
            currContainedView.addSubview(currViewController.view)
            NSLayoutConstraint.activate([
                currViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                currViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                currViewController.view.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
                currViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
                ])
            currentViewController = currViewController
        }
    }
    
    func updateView(newView: CellType) {
        print("newVIEW \(newView)")
        if let currViewController = currentViewController {
            //something exists here so remocve it
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

}
