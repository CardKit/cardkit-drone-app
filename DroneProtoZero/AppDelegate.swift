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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        
        _ = Logger.shared
        DJIHardwareManager.sharedInstance.connectionConfig = .debug("192.168.1.2")
        
        setUpSplitView()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func setUpSplitView() {
        let splitView: SplitViewController = SplitViewController()
        splitView.viewControllers = viewControllersArray()        
        splitView.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        splitView.presentsWithGesture = false
        splitView.maximumPrimaryColumnWidth = 350
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = splitView
    }
    
    func viewControllersArray() -> [UIViewController] {
        guard let controlsNC = UIStoryboard(name: "Library", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let canvasViewNC  = UIStoryboard(name: "Canvas", bundle: nil).instantiateInitialViewController() as? UINavigationController else { return [] }
        return [controlsNC, canvasViewNC]
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Use this method to pause ongoing tasks, disable timers, 
        //and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // If your application supports background execution, 
        //this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; 
        //here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. 
        //If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. 
        //Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
    }

}
