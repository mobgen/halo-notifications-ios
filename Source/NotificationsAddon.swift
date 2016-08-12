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

    // MARK: Addon lifecycle

    public func setup(core: CoreManager, completionHandler handler: ((Addon, Bool) -> Void)? = nil) {
        // Add observer to listen for the token refresh notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationsAddon.onTokenRefresh), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        handler?(self, true)
    }

    public func startup(core: CoreManager, completionHandler handler: ((Addon, Bool) -> Void)? = nil) {
        self.completionHandler = handler

        FIRApp.configure()

        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
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

        if let user = Halo.Manager.core.user, token = FIRInstanceID.instanceID().token() {
            user.devices = [UserDevice(platform: "ios", token: token)]
            Halo.Manager.core.saveUser { _ in
                self.completionHandler?(self, true)
            }
        } else {
            self.completionHandler?(self, true)
        }
    }

    public func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError, core: CoreManager) {

        self.completionHandler?(self, false)
    }

    public func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], core: CoreManager, fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        self.delegate?.haloApplication(application, didReceiveRemoteNotification: userInfo)

        if let silent = userInfo["content_available"] as? String where silent == "1" {
            self.delegate?.haloApplication(application, didReceiveSilentNotification: userInfo, fetchCompletionHandler: completionHandler)
        } else {
            self.delegate?.haloApplication(application, didReceiveNotification: userInfo)
            completionHandler(.NewData)
        }
    }

    @objc
    private func onTokenRefresh() -> Void {

        if let user = Halo.Manager.core.user, token = FIRInstanceID.instanceID().token() {
            user.devices = [UserDevice(platform: "ios", token: token)]
            Halo.Manager.core.saveUser()
        }

    }
}
