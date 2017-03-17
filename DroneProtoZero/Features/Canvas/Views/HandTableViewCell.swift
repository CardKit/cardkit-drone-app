//
//  HandTableViewCell.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

protocol CardViewDelegate: class {
    func cardViewWasSelected(handID: Int, cardID: Int)
}

class HandTableViewCell: UITableViewCell, Reusable {

    var handID: Int = 0
    @IBOutlet weak var collectionView: UICollectionView!
    var isEmpty: Bool {
        get {
            if let cards = currentHand?.cards {
                if cards.count > 0 {
                    return false
                }
            }
            return true
        }
    }
    var currentHand: Hand?
    var cards: [Card]?
    let viewModel: CanvasViewModel = CanvasViewModel()
    weak var cardDelegate: CardViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        cards = nil
        collectionView.isHidden = isEmpty
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupHand(sectionID: Int, delegate: CardViewDelegate) {
        //TODO: Check for existance of Cards in the hand and populate the colectionview
        handID = sectionID
        cardDelegate = delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        currentHand = viewModel.getHand(by: handID)
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
    
    func addCard(card: ActionCardDescriptor) {
        currentHand = viewModel.getHand(by: handID)
        collectionView.isHidden = isEmpty
        
        if let cards = currentHand?.cards {
            //NOTE: has to be greater than 1 because there should alwauys be an END CARD and that card needs to be the last card in the hand ALWAYS, NO IFs, ANDS, OR BUTS about it
            if cards.count > 1 {
                //we insert the new card always as the last card
                let newCardPath = IndexPath(item: cards.count-2, section: 0)
                collectionView.insertItems(at: [newCardPath])
                collectionView.scrollToItem(at: newCardPath, at: UICollectionViewScrollPosition.right, animated: true)
            }
        }
    }
    
    func removeCard(cardIndex: Int) {
        //TODO: how do I figure out what the index is of the card that was removed?
        //its coming from the view model so maybe there's a weya in there
        if let cards = currentHand?.cards {
            if cards.count > 0 {
                let deleteCardPath = IndexPath(item: cardIndex, section: 0)
                collectionView.deleteItems(at:[deleteCardPath])
            }
        }
        
        
    }
    
    func showHovering(isHovering: Bool) {
        if isHovering {
            backgroundColor = .green
        } else {
            backgroundColor = .white
        }
    }
}

extension HandTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentHand?.cards.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let card = currentHand?.cards[indexPath.item],
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell else { return UICollectionViewCell() }
        
        cell.backgroundColor = .black
        switch card.cardType {
        case .action:
            if let actionCard = card as? ActionCard {
                cell.setupCell(card: actionCard.descriptor)
            }
        case .hand:
            if let handCard = card as? HandCard {
                cell.setupCell(card: handCard.descriptor)
            }
        default:
            print("do nothing for ")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("grab the card index and send it to canvas section: \(indexPath.section) card index: \(indexPath.item)")
        cardDelegate?.cardViewWasSelected(handID: handID, cardID: indexPath.item)
    }
}
