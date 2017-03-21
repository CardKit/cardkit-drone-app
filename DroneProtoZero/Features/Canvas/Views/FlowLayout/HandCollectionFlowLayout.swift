//
//  HandCollectionFlowLayout.swift
//  DroneProtoZero
//
//  Created by boland on 3/21/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class HandCollectionFlowLayout: UICollectionViewFlowLayout {

    var indexPathsToAnimateOnScreen: IndexPath?
    var indexPathToAnimateOffScreen: IndexPath?
    
    
    override init() {
        super.init()
        self.itemSize = CGSize(width: CardTableViewCell.cardWidth, height: CardTableViewCell.cardHeight)
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        //If you're a new item being added to the collection, then start from the left and scale in
        guard let indexUpdatePath = indexPathsToAnimateOnScreen else { return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath as IndexPath) }
        if indexUpdatePath == itemIndexPath {
            if let attr = self.layoutAttributesForItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes, let collectionView = self.collectionView {
                let scaleTransform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                attr.transform = scaleTransform
                //starting positiong from the left hand side of the collection to the middle
                attr.center = CGPoint(x: 0.0, y: collectionView.bounds.maxY/2.0)
                return attr
            }
        }
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    
    //Some Fine tuning will need to be done here to get it to look right
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let indexUpdatePath = indexPathToAnimateOffScreen else { return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) }
        if indexUpdatePath == itemIndexPath {
            if let attr = self.layoutAttributesForItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes, let collectionView = self.collectionView {
                let scaleTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                attr.transform = scaleTransform
                attr.center = CGPoint(x: -20.0, y: collectionView.bounds.maxY/2.0)
                return attr
            }
        }
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
    /**
     Checking to see which cells have been inserted or removed and saving them for processing in the fade in/fadeout methods from above
     
     - parameter updateItems:
     */
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        for updatedItem in updateItems {
            print("UPDATED items \(updatedItem)")
            switch updatedItem.updateAction {
            case .insert:
                indexPathsToAnimateOnScreen = updatedItem.indexPathAfterUpdate
                break
            case .delete:
                print("Delete")
                indexPathToAnimateOffScreen = updatedItem.indexPathBeforeUpdate
                indexPathsToAnimateOnScreen = nil
                break
            case .reload:
                print("reload")
                indexPathsToAnimateOnScreen = nil
                break
            case .move:
                print("move")
                indexPathsToAnimateOnScreen = nil
            default:
                //All other animations flow through here
                break
            }
        }
    }
}
