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
    
    let draggingCardOffset: CGFloat = 10.0
    
    var canvasViewController: CanvasViewController?
    
    private var gestureRecognizer: UIGestureRecognizer?
    private var draggingCardView: UIView?
    private var currentCardDescriptor: ActionCardDescriptor?
    private var touchOffset: CGPoint = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //identify canvas view controller for dropping
        if let navController = self.viewControllers[1] as? UINavigationController,
           let canvasVC = navController.topViewController as? CanvasViewController {
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
        
        let touchPoint: CGPoint = (gestureRecognizer?.location(in: self.view))!
        
        switch gesture.state {
        case UIGestureRecognizerState.began :
            if let hitView: UIView = self.view.hitTest(touchPoint, with: nil) {
                if let cell = hitView.superview?.superview as? CardTableViewCell {
                    currentCardDescriptor = cell.cardDescriptor
                    let hitViewPosition = hitView.convert(hitView.frame.origin, to: self.view)
                    draggingCardView = hitView.snapshotView(afterScreenUpdates: false)
                    draggingCardView!.frame = CGRect(x: hitViewPosition.x + draggingCardOffset, y: hitViewPosition.y + draggingCardOffset, width: CardTableViewCell.cardWidth, height: CardTableViewCell.cardHeight)
                    touchOffset.x = touchPoint.x - hitViewPosition.x
                    touchOffset.y = touchPoint.y - hitViewPosition.y
                    self.view.addSubview(draggingCardView!)                    
                }
            }
        case UIGestureRecognizerState.changed :
            if let cardView = draggingCardView {
                cardView.frame = CGRect(x: touchPoint.x - touchOffset.x + draggingCardOffset, y: touchPoint.y - touchOffset.y + draggingCardOffset, width: cardView.frame.size.width, height: cardView.frame.size.height)
            }
        case UIGestureRecognizerState.ended :
            if let cardView = draggingCardView {
                if cardView.frame.intersects((canvasViewController?.tableView.frame)!) {
                    let positionInCanvas: CGPoint = self.view.convert(touchPoint, to: canvasViewController?.view)
                    if let descriptor = currentCardDescriptor {
                        canvasViewController?.addCardToHand(descriptor: descriptor, position: positionInCanvas)
                    }
                }
                cardView.removeFromSuperview()
                draggingCardView = nil
            }
        default:
            break
        }
        
    }
}
