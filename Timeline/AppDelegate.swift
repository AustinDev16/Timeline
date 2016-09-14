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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        // perform any syncing needed from cloud
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        PostController.sharedController.performFullSync()
        
        let newComment = UIAlertController(title: "New comment!", message: "Someone commented on a post you're following.", preferredStyle: .Alert)
        
        let okay = UIAlertAction(title: "Dismiss", style: .Default) { (_) in
            
        }
        
        let view = UIAlertAction(title: "View Post", style: .Default) { (_) in
            // Find which post has the new comment
            
            // Segue to the post
        }
        
        newComment.addAction(okay)
        newComment.addAction(view)
        
        self.window?.rootViewController?.presentViewController(newComment, animated: true, completion: nil)
    }

}

