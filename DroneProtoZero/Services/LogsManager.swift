//
//  LogsManager.swift
//  DroneProtoZero
//
//  Created by ismails on 3/10/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class LogsManager: NSObject {
    static let shared = LogsManager()
    
    var inputPipe: Pipe?
    var outputPipe: Pipe?
    
    var logs: [String] = []
    var LOGS_LENGTH: Int = 300
    
    override init() {
        super.init()
        
        openConsolePipe()
    }
    
    private func addLog(_ log: String) {
        if(logs.count > LOGS_LENGTH) {
            logs.remove(at: 0)
        }
        
        logs.append(log)
    }
    
    private func openConsolePipe() {
        inputPipe = Pipe()
        outputPipe = Pipe()
        
        guard let inputPipe = inputPipe, let outputPipe = outputPipe else {
            return
        }
        
        let pipeReadHandle = inputPipe.fileHandleForReading
        
        dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
        
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePipeNotification), name: FileHandle.readCompletionNotification, object: pipeReadHandle)
        pipeReadHandle.readInBackgroundAndNotify()
    }
    
    func handlePipeNotification(notification: Notification) {
        inputPipe?.fileHandleForReading.readInBackgroundAndNotify()
        
        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data {
            // write back to STDOUT
            outputPipe?.fileHandleForWriting.write(data)
            
            if let str = String(data: data, encoding: String.Encoding.ascii) {
                addLog(str)
            }
        }
    }
}
