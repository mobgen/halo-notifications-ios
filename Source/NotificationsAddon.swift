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
open class NotificationsAddon: NSObject, HaloNotificationsAddon, HaloLifecycleAddon, UNUserNotificationCenterDelegate {
    
    public var completionHandler: ((HaloAddon, Bool) -> Void)?
    public var addonName = "Notifications"
    public var delegate: NotificationsDelegate?
    public var twoFactorDelegate: TwoFactorAuthenticationDelegate?

    fileprivate var autoRegister: Bool = true
    open var token: String?

    /// Token used to make sure the startup process is done only once
    fileprivate var once_token: Int = 0
    
    public init(autoRegister auto: Bool = true) {
        super.init()
        self.autoRegister = auto
    }
    
    // MARK: Addon lifecycle

    open func setup(haloCore core: CoreManager, completionHandler handler: ((HaloAddon, Bool) -> Void)? = nil) {
        // Add observer to listen for the token refresh notification.
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationsAddon.onTokenRefresh), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        handler?(self, true)
    }

    open func startup(app: UIApplication, haloCore core: CoreManager, completionHandler handler: ((HaloAddon, Bool) -> Void)? = nil) {
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        self.completionHandler = handler
        
        if self.autoRegister {
            registerApplicationForNotifications(app)
        } else {
            handler?(self, true)
        }
    }

    public func willRegisterAddon(haloCore core: CoreManager) {
        
    }
    
    public func didRegisterAddon(haloCore core: CoreManager) {
        
    }
    
    public func registerApplicationForNotifications(_ app: UIApplication) {
        if #available(iOS 10.0, *) {
            registerApplicationForNotificationsWithAuthOptions(app)
        } else {
            registerApplicationForNotificationsWithSettings(app)
        }
    }
    
    @available(iOS 10.0, *)
    public func registerApplicationForNotificationsWithAuthOptions(
        _ app: UIApplication,
        authOptions options: UNAuthorizationOptions = [.alert, .badge, .sound]) -> Void {
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: options,
            completionHandler: {_, _ in })
        
        app.registerForRemoteNotifications()
    }
    
    public func registerApplicationForNotificationsWithSettings(
        _ app: UIApplication,
        notificationSettings settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)) -> Void {
        
        app.registerUserNotificationSettings(settings)
        
        app.registerForRemoteNotifications()
    }
    
    // MARK: Lifecycle
    
    @objc(applicationWillFinishLaunching:core:)
    public func applicationWillFinishLaunching(_ app: UIApplication, core: CoreManager) -> Bool {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
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
    
    public func applicationWillChangeEnvironment(_ app: UIApplication, core: CoreManager) {
        app.unregisterForRemoteNotifications()
    }
    
    public func applicationDidChangeEnvironment(_ app: UIApplication, core: CoreManager) {
    }
    
    // MARK: Notifications
    
    open func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data, core: CoreManager) {

        if let device = Halo.Manager.core.device,
            let token = InstanceID.instanceID().token() {
            
            device.info = DeviceInfo(platform: "ios", token: token)
            Halo.Manager.core.saveDevice { _, result in
                
                switch result {
                case .success(_, _):
                    core.logMessage("Successfully registered for remote notifications with Firebase token: \(token)", level: .info)
                    self.completionHandler?(self, true)
                case .failure(let error):
                    core.logMessage("Error saving device: \(error.localizedDescription)", level: .error)
                    self.completionHandler?(self, false)
                }
                
            }
        } else {
            core.logMessage("Error registering for remote notifications. No Firebase token available", level: .error)
            self.completionHandler?(self, false)
        }
    }

    open func application(_ app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError, core: CoreManager) {
        core.logMessage("Error registering for remote notifications. \(error.localizedDescription)", level: .error)
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

        if let device = Halo.Manager.core.device, let token = InstanceID.instanceID().token() {
            device.info = DeviceInfo(platform: "ios", token: token)
            Halo.Manager.core.saveDevice()
        }

    }
}
