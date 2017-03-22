//
//  Logger.swift
//  DroneProtoZero
//
//  Created by ismails on 3/10/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class Logger: NSObject {
    public struct NotificationName {
        static let log = NSNotification.Name("LogNotification")
    }
    
    public enum NotificationKey: String {
        case log
    }
    
    static let shared = Logger()
    
    var inputPipe: Pipe?
    var outputPipe: Pipe?
    
    var logs: [String] = []
    var logsLength: Int = 300
    
    override init() {
        super.init()
    }
    
    public static func log(_ log: String) {
        Logger.shared.addToCache(log)
        NotificationCenter.default.post(name: Logger.NotificationName.log, object: nil, userInfo: [Logger.NotificationKey.log.rawValue: log])
    }
    
    /// Adds log string to logs array. The logs array is capped at LOGS_LENGTH, so if logs array count 
    /// is greater than LOGS_LENGTH, we remove from the beginning of the array. Remove is O(n), at worst case
    /// this is O(n). We can build something that will give us O(1).. a cicular array that keeps track of head/tail
    /// but not sure if this is necessary right now
    ///
    /// - Parameter log: the string that should be added to the logs array
    private func addToCache(_ log: String) {
        if logs.count > logsLength {
            logs.remove(at: 0)
        }
        
        logs.append(log)
    }
    
    /// Starts the process of listening in on any writes to STDOUT and STDERR
    private func openConsolePipe() {
        inputPipe = Pipe()
        outputPipe = Pipe()
        
        guard let inputPipe = inputPipe, let outputPipe = outputPipe else {
            return
        }
        
        let pipeReadHandle = inputPipe.fileHandleForReading
        
        //from documentation
        //dup2() makes newfd (new file descriptor) be the copy of oldfd (old file descriptor), closing newfd first if necessary.
        
        //here we are copying the STDOUT file descriptor into our output pipe's file descriptor
        //this is so we can write the strings back to STDOUT, so it can show up on the xcode console
        dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
        
        //In this case, the newFileDescriptor is the pipe's file descriptor and the old file descriptor is STDOUT_FILENO and STDERR_FILENO
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handlePipeNotification), name: FileHandle.readCompletionNotification, object: pipeReadHandle)
        pipeReadHandle.readInBackgroundAndNotify()
    }
    
    
    /// Handling readCompletionNotification to listen in on any logs that were printed
    ///
    /// - Parameter notification: notification contains info on what was printed/logged
    func handlePipeNotification(notification: Notification) {
        inputPipe?.fileHandleForReading.readInBackgroundAndNotify()
        
        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data {
            //write the data back into the output pipe. the output pipe's write file descriptor points to STDOUT. this allows the logs to show up on the xcode console
            outputPipe?.fileHandleForWriting.write(data)
            
            if let str = String(data: data, encoding: String.Encoding.ascii) {
                addToCache(str)
            }
        }
    }
}
