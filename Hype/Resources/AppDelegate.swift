//
//  AppDelegate.swift
//  Hype
//
//  Created by RYAN GREENBURG on 9/25/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Request user for notification authorization for subscribeForRomoteNotifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { (userDidAllow, error) in
            if let error = error {
                print("======== ERROR ========")
                print("Function: \(#function)")
                print("Error: \(error)")
                print("Description: \(error.localizedDescription)")
                print("======== ERROR ========")
            }
            
            if userDidAllow {
                DispatchQueue.main.async { //registerForRemoteNotifications() need to be in the main thread
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }
    
    // MARK: - 3 Fuctions for RemoteNotifications
    // For testing using your iphone and stimulator
    // didRegisterForRemoteNotificationsWithDeviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // register ==> the (success) can be true or false
        HypeController.shared.subscribeForRomoteNotifications { (success) in
            if success {
                print("We successfully signed up for remote notifiactions.")
            } else {
                print("We failed to sign up for remote notifications.")
            }
        }
    }
    
    // didFailToRegisterForRemoteNotificationsWithError
    // Handler when we are failling ToRegisterForRemoteNotifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // when fail to register, just print out the error.
        print(error)
        print(error.localizedDescription)
    }
    
    // didReceiveRemoteNotification
    // Called didReceiveRemoteNotification ==> What we want to do when we receive RemoteNotification ??
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // if we get notifications back in time, we fetch al hypes.
        HypeController.shared.fetchAllHypes { (result) in
            switch result {
            
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Hey anytime you open this app, set icon badge to 0
        application.applicationIconBadgeNumber = 0
    }
}

