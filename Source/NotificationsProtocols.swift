//
//  NotificationsProtocols.swift
//  HaloNotificationSDK
//
//  Created by Borja Santos-Díez on 21/06/16.
//  Copyright © 2016 Mobgen Technology. All rights reserved.
//

import Foundation
import UIKit

/// Delegate to be implemented to handle push notifications easily
@objc(HaloNotificationsDelegate)
public protocol NotificationsDelegate {
    /**
     This handler will be called when any push notification is received (silent or not)

     - parameter application:       Application receiving the push notification
     - parameter userInfo:          Dictionary containing information about the push notification
     - parameter userInteraction:   Whether the execution of this delegate has been triggered by a user action or not
     */
    func haloApplication(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], userInteraction user: Bool) -> Void

    /**
     This handler will be called when a silent push notification is received

     - parameter application:       Application receiving the silent push notification
     - parameter userInfo:          Dictionary containing information about the push notification
     - parameter completionHandler: Closure to be called after completion
     */
    func haloApplication(application: UIApplication, didReceiveSilentNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)?) -> Void

    /**
     This handler will be called when a push notification is received

     - parameter application:       Application receiving the silent push notification
     - parameter userInfo:          Dictionary containing information about the push notification
     - parameter userInteraction:   Whether the execution of this delegate has been triggered by a user action or not
     */
    func haloApplication(application: UIApplication, didReceiveNotification userInfo: [NSObject : AnyObject], userInteraction user: Bool) -> Void
}
