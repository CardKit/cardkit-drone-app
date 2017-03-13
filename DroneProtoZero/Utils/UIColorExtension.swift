/*
 * IBM Confidential
 *
 * OCO Source Materials
 *
 * Copyright IBM Corporation 2014.
 *
 * The source code for this program is not published or otherwise divested of
 * its trade secrets, irrespective of what has been deposited with the US
 * Copyright Office.
 */

import Foundation
import UIKit

extension UIColor {
    public convenience init(red: Int, green: Int, blue: Int) {
        let red = CGFloat(red)/255, green = CGFloat(green)/255, blue = CGFloat(blue)/255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    // hexString must start with '#'
    convenience init(hexString: String) {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        if hexString.hasPrefix("#") {
            let index =  hexString.index(hexString.startIndex, offsetBy: 1)
            let hex = hexString.substring(from: index)
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                if hex.characters.count == 6 {
                    red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF) / 255.0
                } else if hex.characters.count == 8 {
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                } else {
                    print("invalid hex color string, length should be 7 or 9")
                }
            } else {
                print("scan hex error")
            }
        } else {
            print("invalid hex color string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

// App color scheme
extension UIColor {

    
    static var cornflowerBlue: UIColor {
        return UIColor(hexString: "#6195ED")
    }
    
    static var athensGray: UIColor {
        return UIColor(hexString: "#EFEFF4")
    }
    
    static var dustyGray: UIColor {
        return UIColor(hexString: "#949494")
    }
    
    static var tableViewDefaultBlue: UIColor {
        return UIColor(hexString: "#007AFF")
    }
    
    static var tableViewSeparatorGray: UIColor {
        return UIColor(hexString: "#D1D1D4")
    }
    
    static var textHeaderGray: UIColor {
        return UIColor(hexString: "#7F7F7F")
    }
    
    static var placeholderGray: UIColor {
        return UIColor(hexString: "#C8C7CC")
    }
}
