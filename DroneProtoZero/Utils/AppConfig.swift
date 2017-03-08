//
//  InfoPlistKeys.swift
//  DroneProtoZero
//
//  Created by ismails on 3/8/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit



class AppConfig: NSObject {
    static var infoPlistDict: [String: Any]? {
        get {
            guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else { return nil }
            return NSDictionary(contentsOfFile: path) as? [String: Any]
        }
    }
    
    static var djiAPIKey: String? {
        get {
            guard let infoPlistDict = AppConfig.infoPlistDict else { return nil }
            return infoPlistDict[AppConfig.DJI_API_KEY] as? String
        }
    }
}

// Info.plist Keys
extension AppConfig {
    static let DJI_API_KEY = "DJI API KEY"
}
