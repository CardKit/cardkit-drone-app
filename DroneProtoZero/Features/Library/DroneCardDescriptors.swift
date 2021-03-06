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

import Foundation
import CardKit
import DroneCardKit

struct DroneCardDescriptors {
    
    static let sharedInstance = DroneCardDescriptors()
    
    var all: [String: [ActionCardDescriptor]] = [:]
    
    init() {
        let catalog = DroneCardCatalog()
        for desc in catalog.executableActionTypes.keys {
            if all[desc.path.description] == nil {
                all[desc.path.description] = []
            }
            all[desc.path.description]?.append(desc)
        }
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
