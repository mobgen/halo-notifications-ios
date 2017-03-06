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
    func haloApplication(_ application: UIApplication, didReceiveRemoteNotification notification: HaloNotification, userInteraction user: Bool, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)?) -> Void
    
    
}
