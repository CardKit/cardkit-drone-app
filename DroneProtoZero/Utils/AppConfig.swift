//
//  InfoPlistKeys.swift
//  DroneProtoZero
//
//  Created by ismails on 3/8/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import Foundation

class AppConfig {
    // Info.plist Keys
    public enum Keys: String {
        case djiAPIKey = "DJI API KEY"
    }
    
    static var infoPlistDict: [String: Any]? {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else { return nil }
        return NSDictionary(contentsOfFile: path) as? [String: Any]
    }
    
    static var djiAPIKey: String? {
        guard let infoPlistDict = AppConfig.infoPlistDict else { return nil }
        return infoPlistDict[AppConfig.Keys.djiAPIKey.rawValue] as? String
    }
}
