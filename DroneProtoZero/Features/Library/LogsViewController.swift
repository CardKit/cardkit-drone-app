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

class LogsViewController: UIViewController {

    @IBOutlet weak var logView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logView?.text = Logger.shared.logs.joined(separator: "\n")
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogsViewController.handleLogNotification), name: Logger.NotificationName.log, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notification Handler
    @objc func handleLogNotification(notification: Notification) {
        guard let str = notification.userInfo?[Logger.NotificationKey.log.rawValue] as? String else { return }
        
        DispatchQueue.main.async {
            self.logView?.text.append("\(str) \n")
            self.logView?.scrollToBottom()
        }
    }
    
    func handlePipeNotification(notification: Notification) {
        guard let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data, let str = String(data: data, encoding: String.Encoding.ascii) else { return }
        
        DispatchQueue.main.async {
            self.logView?.text.append("\(str) \n")
            self.logView?.scrollToBottom()
        }
    }
}
