/**
 * Copyright 2018 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import CardKit

class SplitViewController: UISplitViewController {
    
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
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(gesture:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        self.gestureRecognizer = gestureRecognizer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Drag and Drop
    
    @objc func onLongPressGesture(gesture: UIGestureRecognizer) {
        
        guard let touchPoint: CGPoint = (gestureRecognizer?.location(in: self.view)) else { return }
        
        switch gesture.state {
        case UIGestureRecognizerState.began :
           createDraggingView(touchPoint: touchPoint)
        case UIGestureRecognizerState.changed :
            if let cardView = draggingCardView {
               cardView.frame = CGRect(x: touchPoint.x - touchOffset.x, y: touchPoint.y - touchOffset.y, width: cardView.frame.size.width, height: cardView.frame.size.height)
                let positionInCanvas: CGPoint = self.view.convert(touchPoint, to: canvasViewController?.hoverableView)
                canvasViewController?.showHovering(position: positionInCanvas)
            }
        case UIGestureRecognizerState.ended :
            guard let cardView = draggingCardView else { break }
            addDraggedViewTo(cardView: cardView, touchPoint: touchPoint)
            
        default:
            guard let cardView = draggingCardView else { break }
            cardView.removeFromSuperview()
            draggingCardView = nil
            canvasViewController?.cancelHovering()
            break
        }
        
    }
    
    func draggingViewIsTouching(view: UIView, point: CGPoint) -> Bool {
        guard let canvasVC = canvasViewController else { return false }
        return canvasVC.isViewHovering(view: view, touchPoint: point)
    }
    
    func createDraggingView(touchPoint: CGPoint) {
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
                animate(onScreen: true, view: cardView, position: CGPoint(x: cardView.frame.origin.x, y: cardView.frame.origin.y), completion: nil)
            }
        }

    }
    
    func addDraggedViewTo(cardView: UIView, touchPoint: CGPoint) {
        if draggingViewIsTouching(view: cardView, point: touchPoint) {
            let positionInCanvas: CGPoint = self.view.convert(touchPoint, to: canvasViewController?.hoverableView)
            if let descriptor = currentCardDescriptor {
                canvasViewController?.addItemToView(item: descriptor, position: positionInCanvas)
                animate(onScreen: false, view: cardView, position: CGPoint(x: touchPoint.x, y: touchPoint.y), completion: {
                    cardView.removeFromSuperview()
                    self.draggingCardView = nil
                })
            }
        } else {
            cardView.removeFromSuperview()
            canvasViewController?.cancelHovering()
            draggingCardView = nil
        }
    }
    
    func addDropShadow(to view: UIView) {
        view.layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        view.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        view.layer.shadowRadius = 5.0
        view.layer.shadowOpacity = 0.4
    }
    
    func animate(onScreen: Bool, view: UIView, position: CGPoint, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
            if onScreen {
                view.frame = CGRect(x: position.x, y: position.y, width: CardTableViewCell.cardWidth, height: CardTableViewCell.cardHeight)
            }
            let scale:CGFloat = onScreen ? 1.05 : 0.5
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { (_) in
            let finScale: CGFloat = onScreen ? 1.0 : 0.0
            view.transform = CGAffineTransform(scaleX: finScale, y: finScale)
            if let completion = completion {
                completion()
            }
        })
    }
}
