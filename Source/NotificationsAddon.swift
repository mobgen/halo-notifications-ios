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
open class NotificationsAddon: NSObject, Halo.NotificationsAddon {

    open var addonName = "Notifications"
    open var delegate: NotificationsDelegate?

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
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }

    public func willRegisterAddon(haloCore core: CoreManager) {
        
    }
    
    public func didRegisterAddon(haloCore core: CoreManager) {
        
    }
    
    // MARK: Notifications

    open func application(application app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data, core: CoreManager) {

        if let device = Halo.Manager.core.device, let token = FIRInstanceID.instanceID().token() {
            device.info = DeviceInfo(platform: "ios", token: token)
            Halo.Manager.core.saveDevice { _ in
                self.completionHandler?(self, true)
            }
        } else {
            self.completionHandler?(self, true)
        }
    }

    open func application(application app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError, core: CoreManager) {

        self.completionHandler?(self, false)
    }

    open func application(application app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], core: CoreManager, userInteraction user: Bool, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        self.delegate?.haloApplication(app, didReceiveRemoteNotification: userInfo, userInteraction: user)

        if let silent = userInfo["content_available"] as? String , silent == "1" {
            self.delegate?.haloApplication(app, didReceiveSilentNotification: userInfo, fetchCompletionHandler: completionHandler)
        } else {
            self.delegate?.haloApplication(app, didReceiveNotification: userInfo, userInteraction: user)
            completionHandler(.newData)
        }
    }

    @objc
    fileprivate func onTokenRefresh() -> Void {

        if let device = Halo.Manager.core.device, let token = FIRInstanceID.instanceID().token() {
            device.info = DeviceInfo(platform: "ios", token: token)
            Halo.Manager.core.saveDevice()
        }

    }
}
