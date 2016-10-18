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

@objc(HaloNotificationsAddon)
public class NotificationsAddon: NSObject, Halo.NotificationsAddon {

    public var addonName = "Notifications"
    public var delegate: NotificationsDelegate?

    private var completionHandler: ((Addon, Bool) -> Void)?
    public var token: String?

    /// Token used to make sure the startup process is done only once
    private var once_token: dispatch_once_t = 0
    
    // MARK: Addon lifecycle

    @objc(setup:completionHandler:)
    public func setup(haloCore core: CoreManager, completionHandler handler: ((Addon, Bool) -> Void)? = nil) {
        // Add observer to listen for the token refresh notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationsAddon.onTokenRefresh), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        handler?(self, true)
    }

    @objc(startup:completionHandler:)
    public func startup(haloCore core: CoreManager, completionHandler handler: ((Addon, Bool) -> Void)? = nil) {
        self.completionHandler = handler

        dispatch_once(&once_token) {
            FIRApp.configure()
        }

        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    @objc(willRegisterAddon:)
    public func willRegisterAddon(haloCore core: CoreManager) {

    }
    
    @objc(didRegisterAddon:)
    public func didRegisterAddon(haloCore core: CoreManager) {

    }

    // MARK: Device

    @objc(willRegisterDevice:)
    public func willRegisterDevice(haloCore core: CoreManager) {

    }

    @objc(didRegisterDevice:)
    public func didRegisterDevice(haloCore core: CoreManager) {

    }

    // MARK: Application lifecycle

    @objc(applicationDidFinishLaunching:core:)
    public func applicationDidFinishLaunching(application app: UIApplication, core: CoreManager) {

    }

    @objc(applicationDidBecomeActive:core:)
    public func applicationDidBecomeActive(application app: UIApplication, core: CoreManager) {

    }

    @objc(applicationDidEnterBackground:core:)
    public func applicationDidEnterBackground(application app: UIApplication, core: CoreManager) {

    }

    // MARK: Notifications

    @objc(application:didRegisterForRemoteNotificationsWithDeviceToken:core:)
    public func application(application app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData, core: CoreManager) {

        if let device = Halo.Manager.core.device, let token = FIRInstanceID.instanceID().token() {
            device.info = DeviceInfo(platform: "ios", token: token)
            Halo.Manager.core.saveDevice { _ in
                self.completionHandler?(self, true)
            }
        } else {
            self.completionHandler?(self, true)
        }
    }

    @objc(application:didFailToRegisterForRemoteNotificationsWithError:core:)
    public func application(application app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError, core: CoreManager) {

        self.completionHandler?(self, false)
    }

    @objc(application:didReceiveRemoteNotification:core:fetchCompletionHandler:)
    public func application(application app: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], core: CoreManager, fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        self.delegate?.haloApplication(app, didReceiveRemoteNotification: userInfo)

        if let silent = userInfo["content_available"] as? String where silent == "1" {
            self.delegate?.haloApplication(app, didReceiveSilentNotification: userInfo, fetchCompletionHandler: completionHandler)
        } else {
            self.delegate?.haloApplication(app, didReceiveNotification: userInfo)
            completionHandler(.NewData)
        }
    }

    @objc
    private func onTokenRefresh() -> Void {

        if let device = Halo.Manager.core.device, let token = FIRInstanceID.instanceID().token() {
            device.info = DeviceInfo(platform: "ios", token: token)
            Halo.Manager.core.saveDevice()
        }

    }
}
