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
        
        //If you're a new item being added to the collection, then start from the left and scale in starting at 0.2
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
    
    //if your being removed from the screen then you scale down to 0.1 and you move to your left
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
            switch updatedItem.updateAction {
            case .insert:
                indexPathsToAnimateOnScreen = updatedItem.indexPathAfterUpdate
                break
            case .delete:
                indexPathToAnimateOffScreen = updatedItem.indexPathBeforeUpdate
                //nil out the saved animate on screen index otherwise it will attempt to animate on screen again after this one is done disappearing
                indexPathsToAnimateOnScreen = nil
                break
            case .reload:
                indexPathsToAnimateOnScreen = nil
                break
            default:
                //All other animations flow through here
                break
            }
        }
    }
}
