//
//  AppDelegate.swift
//  Timeline
//
//  Created by Austin Blaser on 9/5/16.
//  Copyright © 2016 Austin Blaser. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        UIApplication.shared.registerForRemoteNotifications()
        
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // perform any syncing needed from cloud
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.sharedController.performFullSync()
        
        let newComment = UIAlertController(title: "New comment!", message: "Someone commented on a post you're following.", preferredStyle: .alert)
        
        let okay = UIAlertAction(title: "Dismiss", style: .default) { (_) in
            
        }
        
        let view = UIAlertAction(title: "View Post", style: .default) { (_) in
            // Find which post has the new comment
            
            // Segue to the post
        }
        
        newComment.addAction(okay)
        newComment.addAction(view)
        
        self.window?.rootViewController?.present(newComment, animated: true, completion: nil)
    }

}

