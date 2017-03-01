//
//  DroneCardDescriptors.swift
//  DroneProtoZero
//
//  Singleton to store all card descriptors.  Convenience functions for accessing descriptors.
//
//  Created by Kristina M Brimijoin on 3/1/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation
import CardKit
import DroneCardKit

struct DroneCardDescriptors {
    static let sharedInstance = DroneCardDescriptors()
    var all: [String: [ActionCardDescriptor]]
    
    init() {        
        all = DroneCardKit.allCardsGrouped()
    }
    
    func keyAtIndex(index: Int) -> String? {
        let keys = Array(all.keys)        
        return keys[index]
    }
    
    func descriptorsAtGroupIndex(index: Int) -> [ActionCardDescriptor]? {
        let keys = Array(all.keys)
        let key = keys[index]
        return all[key]
    }
    
    func descriptorAtIndexPath(indexPath: IndexPath) -> ActionCardDescriptor? {
        let keys = Array(all.keys)
        return all[keys[indexPath.section]]?[indexPath.row]
    }
}
