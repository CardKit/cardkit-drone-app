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
import UIKit

extension UITableView {
    public func dequeueReusableCell<T: Reusable>() -> T {
        guard let cell =  dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else { fatalError("Cannot dequeue a reusable cell with the reuse identifier \(T.reuseIdentifier)")}
        return cell
    }
    
    public func dequeueReusableCell<T: Reusable>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as? T else { fatalError("Cannot dequeue a reusable cell with the reuse identifier \(T.reuseIdentifier)")}
        return cell
    }
}
