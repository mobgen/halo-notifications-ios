//
//  NotificationsManager.swift
//  HaloNotificationSDK
//
//  Created by Borja Santos-Díez on 21/06/16.
//  Copyright © 2016 Mobgen Technology. All rights reserved.
//

import Foundation
import UserNotifications
import Halo
import UIKit
import Firebase
import FirebaseInstanceID

@objc(HaloNotificationsAddon)
open class NotificationsAddon: NSObject, Halo.NotificationsAddon, Halo.LifecycleAddon, UNUserNotificationCenterDelegate {
    
    public var addonName = "Notifications"
    public var delegate: NotificationsDelegate?
    public var twoFactorDelegate: TwoFactorAuthenticationDelegate?

    fileprivate var completionHandler: ((Addon, Bool) -> Void)?
    open var token: String?

    /// Token used to make sure the startup process is done only once
    fileprivate var once_token: Int = 0
    
    // MARK: Addon lifecycle

    open func setup(haloCore core: CoreManager, completionHandler handler: ((Addon, Bool) -> Void)? = nil) {
        // Add observer to listen for the token refresh notification.
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationsAddon.onTokenRefresh), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        handler?(self, true)
    }

    open func startup(haloCore core: CoreManager, completionHandler handler: ((Addon, Bool) -> Void)? = nil) {
        self.completionHandler = handler

        if FIRApp.defaultApp() == nil {
            FIRApp.configure()
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }

    public func willRegisterAddon(haloCore core: CoreManager) {
        
    }
    
    public func didRegisterAddon(haloCore core: CoreManager) {
        
    }
    
    // MARK: Lifecycle
    
    @objc(applicationWillFinishLaunching:core:)
    public func applicationWillFinishLaunching(_ app: UIApplication, core: CoreManager) -> Bool {
        
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            app.registerUserNotificationSettings(settings)
        }
        
        return true
    }
    
    @objc(applicationDidFinishLaunching:core:launchOptions:)
    public func applicationDidFinishLaunching(_ app: UIApplication, core: CoreManager, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
        return true
    }
    
    public func applicationDidBecomeActive(_ app: UIApplication, core: CoreManager) {
        
    }
    
    public func applicationDidEnterBackground(_ app: UIApplication, core: CoreManager) {
        
    }
    
    // MARK: Notifications

    open func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data, core: CoreManager) {

        if let device = Halo.Manager.core.device, let token = FIRInstanceID.instanceID().token() {
            device.info = DeviceInfo(platform: "ios", token: token)
            Halo.Manager.core.saveDevice { _ in
                self.completionHandler?(self, true)
            }
        } else {
            self.completionHandler?(self, true)
        }
    }

    open func application(_ app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError, core: CoreManager) {

        self.completionHandler?(self, false)
    }
    
    open func application(_ app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], core: CoreManager, userInteraction user: Bool, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let notification = HaloNotification(userInfo: userInfo)
        
        if notification.type == .twoFactor {
            if let code = notification.payload["code"] as? String {
                self.twoFactorDelegate?.application(app, didReceiveTwoFactorAuthCode: code, remoteNotification: notification)
            } else {
                Halo.Manager.core.logMessage("No 'code' field was found within the payload", level: .error)
            }
        }
        
        self.delegate?.application(app, didReceiveRemoteNotification: notification, userInteraction: user, fetchCompletionHandler: completionHandler)
    }

    @objc
    fileprivate func onTokenRefresh() -> Void {

        if let device = Halo.Manager.core.device, let token = FIRInstanceID.instanceID().token() {
            device.info = DeviceInfo(platform: "ios", token: token)
            Halo.Manager.core.saveDevice()
        }

    }
}
