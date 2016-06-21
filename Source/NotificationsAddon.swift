//
//  NotificationsManager.swift
//  HaloNotificationSDK
//
//  Created by Borja Santos-Díez on 21/06/16.
//  Copyright © 2016 Mobgen Technology. All rights reserved.
//

import Foundation
import Halo
import UIKit
import Firebase
import FirebaseInstanceID

public class NotificationsAddon: NSObject, Halo.Addon {
    
    public var addonName = "Notifications"
    public var delegate: NotificationsDelegate?
    
    private var completionHandler: ((Addon, Bool) -> Void)?
    public var token: String?
    
    // MARK: Addon lifecycle
    
    public func setup(core: CoreManager, completionHandler handler: ((Bool) -> Void)?) {
        // Add observer to listen for the token refresh notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationsAddon.onTokenRefresh), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        handler?(true)
    }
    
    public func startup(core: CoreManager, completionHandler handler: ((Addon, Bool) -> Void)?) {
        self.completionHandler = handler
        
        FIRApp.configure()
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        handler?(self, true)
    }
    
    public func willRegisterAddon(core: CoreManager) {
        
    }
    
    public func didRegisterAddon(core: CoreManager) {
        
    }
    
    // MARK: User
    
    public func willRegisterUser(core: CoreManager) {
        
    }
    
    public func didRegisterUser(core: CoreManager) {
        
    }
    
    // MARK: Application lifecycle
    
    public func applicationDidFinishLaunching(application: UIApplication, core: CoreManager) {
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication, core: CoreManager) {
        
    }
    
    public func applicationDidEnterBackground(application: UIApplication, core: CoreManager) {
        
    }
    
    // MARK: Notifications
    
    public func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData, core: CoreManager) {
        self.token = FIRInstanceID.instanceID().token()
        self.completionHandler?(self, true)
    }
    
    public func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError, core: CoreManager) {
        
        self.completionHandler?(self, false)
    }
    
    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], core: CoreManager, fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        self.delegate?.haloApplication(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        
        if let silent = userInfo["content_available"] as? String {
            if silent == "1" {
                self.delegate?.haloApplication(application, didReceiveSilentNotification: userInfo, fetchCompletionHandler: completionHandler)
            } else {
                let notif = UILocalNotification()
                notif.alertBody = userInfo["body"] as? String
                notif.soundName = userInfo["sound"] as? String
                notif.userInfo = userInfo
                
                application.presentLocalNotificationNow(notif)
            }
        } else {
            self.delegate?.haloApplication(application, didReceiveNotification: userInfo, fetchCompletionHandler: completionHandler)
        }
    }
    
    public func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification, core: CoreManager) {
        if let userInfo = notification.userInfo {
            self.delegate?.haloApplication(application, didReceiveNotification: userInfo, fetchCompletionHandler: nil)
        }
    }
    
    @objc
    private func onTokenRefresh() -> Void {
        self.token = FIRInstanceID.instanceID().token()
    }
}