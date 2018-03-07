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
