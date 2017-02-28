//
//  DispatchQueueExtensions.swift
//  DroneCardKit
//
//  Created by ismails on 1/30/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public typealias AsyncExecutionCompletionHandler = (Error?) -> Void

extension DispatchQueue {
    public static func executeSynchronously(asyncMethod method: (AsyncExecutionCompletionHandler?) -> Void) throws {
        let semaphore = DispatchSemaphore(value: 0)
        var methodError: Error? = nil

        method({ error in
            methodError = error
            semaphore.signal()
        })
        
        semaphore.wait()
        
        if let error = methodError {
            throw error
        }
    }
}
