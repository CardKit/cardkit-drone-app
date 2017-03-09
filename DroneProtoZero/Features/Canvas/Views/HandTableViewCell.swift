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
    var isEmpty: Bool = true
    var cards: [Card]?
    let viewModel: CanvasViewModel = CanvasViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupHand(sectionID: Int) {
        handID = sectionID
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = isEmpty
    }
    
    func addCard(card: ActionCardDescriptor) {
        isEmpty = false
        collectionView.isHidden = isEmpty
        let currCards = viewModel.getHand(by: handID)
        cards = currCards?.cards
        
        //update the data source
        // TODO: take the card and add it to the collectionview
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
        print("return card could \(cards?.count)")
        return cards?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let card = cards?[indexPath.item] as? ActionCard else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath)
        
        cell.backgroundColor = .black
        (cell as! CardCollectionViewCell).setupCell(card: card.descriptor)
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//      not sure i actually need this
//    }
    
}
