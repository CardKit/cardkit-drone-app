//
//  SplitViewController.swift
//  DroneProtoZero
//
//  Handles the dragging of a card from the library to a hand.
//
//  Created by Kristina M Brimijoin on 3/1/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class SplitViewController: UISplitViewController {
    
    let draggingCardOffset: CGFloat = 0.0
    
    var canvasViewController: Hoverable?
    
    private var gestureRecognizer: UIGestureRecognizer?
    private var draggingCardView: UIView?
    private var currentCardDescriptor: ActionCardDescriptor?
    private var touchOffset: CGPoint = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //identify canvas view controller for dropping
        if let navController = self.viewControllers[1] as? UINavigationController,
           let canvasVC = navController.topViewController as? Hoverable {
            self.canvasViewController = canvasVC
        }
        
        //drag and drop
        self.gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(gesture:)))
        self.view.addGestureRecognizer(gestureRecognizer!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Drag and Drop
    
    func onLongPressGesture(gesture: UIGestureRecognizer) {
        
        guard let touchPoint: CGPoint = (gestureRecognizer?.location(in: self.view)) else { return }
        
        switch gesture.state {
        case UIGestureRecognizerState.began :
            if let hitView: UIView = self.view.hitTest(touchPoint, with: nil) {
                if let cell = hitView.superview?.superview as? CardTableViewCell {
                    currentCardDescriptor = cell.cardDescriptor
                    let hitViewPosition = hitView.convert(hitView.frame.origin, to: self.view)
                    guard let cardView = hitView.snapshotView(afterScreenUpdates: false) else { return }
                    addDropShadow(to: cardView)
                    cardView.center = CGPoint(x: hitViewPosition.x, y: hitViewPosition.y + CardTableViewCell.cardHeight/2)
                    touchOffset.x = touchPoint.x - hitViewPosition.x
                    touchOffset.y = touchPoint.y - hitViewPosition.y
                    cardView.frame = CGRect(x: cardView.frame.origin.x, y: cardView.frame.origin.y, width: 80.0, height: 100.0)
                    self.view.addSubview(cardView)
                    self.draggingCardView = cardView
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                        cardView.frame = CGRect(x: cardView.frame.origin.x, y: cardView.frame.origin.y, width: CardTableViewCell.cardWidth, height: CardTableViewCell.cardHeight)
                        cardView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    }, completion: { (_) in
                        cardView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    })
                }
            }
        case UIGestureRecognizerState.changed :
            if let cardView = draggingCardView {
                cardView.frame = CGRect(x: touchPoint.x - touchOffset.x + draggingCardOffset, y: touchPoint.y - touchOffset.y + draggingCardOffset, width: cardView.frame.size.width, height: cardView.frame.size.height)
                    let positionInCanvas: CGPoint = self.view.convert(touchPoint, to: canvasViewController?.hoverableView)
                    canvasViewController?.showHovering(position: positionInCanvas)

            }
        case UIGestureRecognizerState.ended :
            if let cardView = draggingCardView {
                if draggingViewIsTouching(view: cardView) {
                    let positionInCanvas: CGPoint = self.view.convert(touchPoint, to: canvasViewController?.hoverableView)
                    if let descriptor = currentCardDescriptor {
                        canvasViewController?.addItemToView(item: descriptor, position: positionInCanvas)
                    }
                }
                cardView.removeFromSuperview()
                draggingCardView = nil
            }
        default:
            if let cardView = draggingCardView {
                cardView.removeFromSuperview()
                draggingCardView = nil
            }

            break
        }
        
    }
    
    func draggingViewIsTouching(view: UIView) -> Bool {
        guard let canvasVC = canvasViewController else { return false }
        return canvasVC.isViewHovering(view: view)
    }
    
    func addDropShadow(to view: UIView) {
        view.layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        view.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        view.layer.shadowRadius = 5.0
        view.layer.shadowOpacity = 0.4
    }
}
