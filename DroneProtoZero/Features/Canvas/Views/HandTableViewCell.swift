//
//  HandTableViewCell.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import CardKit

class HandTableViewCell: UITableViewCell, Reusable {

    var handID: Int = 0
    @IBOutlet weak var collectionView: UICollectionView!
    var isEmpty: Bool {
        get {
            if let cards = cards {
                if cards.count > 0 {
                    return false
                }
            }
            return true
        }
    }
    var cards: [Card]?
    let viewModel: CanvasViewModel = CanvasViewModel()
    
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
    
    func setupHand(sectionID: Int) {
        //TODO: Check for existance of Cards in the hand and populate the colectionview
        handID = sectionID
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let currHand = viewModel.getHand(by: handID)
        cards = currHand?.cards
        print("Hand : \(handID) Cards: \(cards)")
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }
    
    func addCard(card: ActionCardDescriptor) {
        let currCards = viewModel.getHand(by: handID)
        cards = currCards?.cards
        collectionView.isHidden = isEmpty
        
        //update the data source
        //collectionView.insertItems(at: <#T##[IndexPath]#>)
        collectionView.reloadData()
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
        return cards?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let card = cards?[indexPath.item],
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
}
