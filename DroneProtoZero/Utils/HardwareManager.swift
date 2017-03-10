//
//  HardwareManager.swift
//  DroneProtoZero
//
//  Created by ismails on 3/8/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit
import DJISDK

// MARK: - ENUMS

public enum DJIConnectionConfiguration {
    case debug(String) // this string is the ip address to connect to
    case release
}

public enum ConnectionStatus {
    case unknown
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
    
    var status: ConnectionStatus = .unknown {
        didSet {
            NotificationCenter.default.post(name: NotificationName.statusUpdated, object: nil, userInfo: [NotificationInfoKey.connectionStatus.rawValue:self.status])
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
        switch status {
        case .connectionSuccessful(_):
            return
        default:
            break;
        }
        
        guard let apiKey = AppConfig.djiAPIKey else { throw DJIConnectionError.apiKeyNotSet("API Key was not set in Info.plist. Please add the API Key in Info.plist with the name as \"DJI API Key\".") }
        
        DJISDKManager.registerApp(apiKey, with: self)
    }
}

extension DJIHardwareManager: DJISDKManagerDelegate {
    
    /// Gets called when the SDK has registered succesfully. Once registered, we will begin connection to the drone.
    func sdkManagerDidRegisterAppWithError(_ error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            self.status = .failedToConnectToSDK(error.localizedDescription)
        } else {
            print("DJISDK Registered Successfully")
            
            switch connectionConfig {
            case .debug(let ipAddress):
                DJISDKManager.enterDebugMode(withDebugId: ipAddress)
            case .release:
                let connStatus = DJISDKManager.startConnectionToProduct()
                
                if connStatus {
                    print("Looking for DJI Products...")
                }
            }
            
            status = .searchingForProducts("Searching for DJI Products")
        }
    }
    
    
    /// Gets called when a product gets detected or updated. Once this function is called and 
    /// newProduct is not nil, we know we have a successful connection to the drone.
    func sdkManagerProductDidChange(from oldProduct: DJIBaseProduct?, to newProduct: DJIBaseProduct?) {
        print("DroneHardwareManager > sdkManagerProductDidChange(from: \(oldProduct), to: \(newProduct)")
        
        guard let newProduct = newProduct else {
            print("DroneHardwareManager > status: No Product Connected (Product Disconnected)")
            connectedDJIProduct = nil
            status = .disconnected("Product was disconnected")
            return
        }
        
        // set connected dji product
        connectedDJIProduct = newProduct
        
        //Updates the product's model
        if let model = newProduct.model {
            print("Model: \((model))")
            print("Product changed from: \(model) to \(model)")
        }
        
        //Updates the product's firmware version - COMING SOON
        newProduct.getFirmwarePackageVersion { (version: String?, _ : Error?) -> Void in
            print("Firmware package version is: \(version ?? "Unknown")")
        }
        
        status = .connectionSuccessful(newProduct.model ?? "Model Information Not Found")
        
        //Updates the product's connection status
        print("Status: Product Connected")
    }
}
