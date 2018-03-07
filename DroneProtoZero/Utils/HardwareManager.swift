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

import UIKit
import DJISDK

// MARK: - ENUMS

public enum DJIConnectionConfiguration {
    case debug(String) // this string is the ip address to connect to
    case release
}

public enum ConnectionStatus {
    case failedToConnectToSDK(String)
    case disconnected(String)
    case searchingForProducts(String)
    case connectionSuccessful(String)
}

public enum DJIConnectionError: Error {
    case apiKeyNotSet(String)
    case debugIPNotSet(String)
}

public enum HardwareManagerNotification: String {
    case statusUpdated = "HardwareStatusUpdated"
}

// MARK: - PROTOCOL

protocol HardwareManager {
    // instance vars
    var status: ConnectionStatus { get }
    
    // functions
    func connect() throws
}

// MARK: - DJIHardwareManager

class DJIHardwareManager: NSObject, HardwareManager {
    public struct NotificationName {
        static let statusUpdated = NSNotification.Name("HardwareStatusUpdated")
    }
    
    public struct NotificationInfoKey {
        static let connectionStatus = NSNotification.Name("ConnectionStatus")
    }
    
    static let sharedInstance: DJIHardwareManager = DJIHardwareManager()
    
    var status: ConnectionStatus = .disconnected("Did not start connection to drone") {
        didSet {
            NotificationCenter.default.post(name: NotificationName.statusUpdated, object: nil, userInfo: [NotificationInfoKey.connectionStatus.rawValue: self.status])
        }
    }
    
    var connectionConfig: DJIConnectionConfiguration = .release
    
    var connectedDJIProduct: DJIBaseProduct?
    
    var djiAircraft: DJIAircraft? {
        return connectedDJIProduct as? DJIAircraft
    }
    
    var djiCamera: DJICamera? {
        return (connectedDJIProduct as? DJIAircraft)?.camera
    }
    
    var djiGimbal: DJIGimbal? {
        return (connectedDJIProduct as? DJIAircraft)?.gimbal
    }
    
    /// This will begin the connection process to the drone. If the status is connectionSuccessful, we do not try to connect again.
    ///
    /// - Throws: throws an error
    func connect() throws {
        Logger.log("\nConnecting to drone.")
        
        switch status {
        case .connectionSuccessful(_):
            Logger.log("Already connected to drone.")
            return
        default:
            break
        }
        
        guard let apiKey = AppConfig.djiAPIKey else {
            let errorMessage = "API Key was not set in Info.plist. Please add the API Key in Info.plist with the name as \"DJI API Key\"."
            Logger.log(errorMessage)
            throw DJIConnectionError.apiKeyNotSet(errorMessage)
        }
        
        Logger.log("Registering App with DJI SDK")
        DJISDKManager.registerApp(apiKey, with: self)
    }
}

extension DJIHardwareManager: DJISDKManagerDelegate {
    
    /// Gets called when the SDK has registered succesfully. Once registered, we will begin connection to the drone.
    func sdkManagerDidRegisterAppWithError(_ error: Error?) {
        if let error = error {
            Logger.log("Error with registering with DJI SDK. \(error.localizedDescription)")
            self.status = .failedToConnectToSDK(error.localizedDescription)
        } else {
            Logger.log("DJISDK Registered Successfully")
            
            switch connectionConfig {
            case .debug(let ipAddress):
                Logger.log("Searching for drones in debug mode with this IP: \(ipAddress). Make sure the bridge app is up and running.")
                DJISDKManager.enterDebugMode(withDebugId: ipAddress)
            case .release:
                let connStatus = DJISDKManager.startConnectionToProduct()
                
                if connStatus {
                    Logger.log("Searching for drones in release mode. Make sure the device is connected to the drone")
                } else {
                    Logger.log("Failed to start connection to drone in release mode.")
                }
            }
            
            status = .searchingForProducts("Searching for DJI Products")
        }
    }
    
    
    /// Gets called when a product gets detected or updated. Once this function is called and 
    /// newProduct is not nil, we know we have a successful connection to the drone.
    func sdkManagerProductDidChange(from oldProduct: DJIBaseProduct?, to newProduct: DJIBaseProduct?) {
        Logger.log("DroneHardwareManager > sdkManagerProductDidChange(from: \(oldProduct), to: \(newProduct)")
        
        guard let newProduct = newProduct else {
            Logger.log("Drone was disconnected.")
            connectedDJIProduct = nil
            status = .disconnected("Product was disconnected")
            return
        }
        
        Logger.log("Connected to drone: ")
        
        // set connected dji product
        connectedDJIProduct = newProduct
        
        //Updates the product's model
        if let model = newProduct.model {
            Logger.log("\tModel: \((model))")
            Logger.log("\tProduct changed from: \(model) to \(model)")
        }
        
        //Updates the product's firmware version - COMING SOON
        newProduct.getFirmwarePackageVersion { (version: String?, _ : Error?) -> Void in
            Logger.log("\tFirmware package version is: \(version ?? "Unknown")")
        }
        
        status = .connectionSuccessful(newProduct.model ?? "Model Information Not Found")
    }
}
