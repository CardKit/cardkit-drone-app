//
//  LogsViewController.swift
//  DroneProtoZero
//
//  Created by boland on 2/27/17.
//  Copyright © 2017 IBM Research. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController {

    @IBOutlet weak var logView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logView?.text = LogsManager.shared.logs.joined(separator: "\n")
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogsViewController.handlePipeNotification), name: FileHandle.readCompletionNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notification Handler
    func handlePipeNotification(notification: Notification) {
        if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data, let str = String(data: data, encoding: String.Encoding.ascii) {
            logView?.text.append("\(str) \n")
            logView?.scrollToBottom()
        }
    }
}

extension UITextView {
    func scrollToBottom() {
        let range = NSMakeRange(self.text.characters.count - 1, 0)
        self.scrollRangeToVisible(range)
    }
}
