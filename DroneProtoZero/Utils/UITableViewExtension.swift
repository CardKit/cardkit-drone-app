/*
 * IBM Confidential
 *
 * OCO Source Materials
 *
 * Copyright IBM Corporation 2016.
 *
 * The source code for this program is not published or otherwise divested of
 * its trade secrets, irrespective of what has been deposited with the US
 * Copyright Office.
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
