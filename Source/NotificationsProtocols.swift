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
    
    /// This handler will be called when any push notification is received (silent or not)
    ///
    /// - Parameters:
    ///   - app: Application receiving the push notification
    ///   - notification: Object containing information about the push notification
    ///   - user: Whether the execution of this delegate has been triggered by a user action or not
    ///   - completionHandler: Handler to be executed for silent notifications (to
    func application(_ app: UIApplication, didReceiveRemoteNotification notification: HaloNotification, userInteraction user: Bool, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)?) -> Void
    
    func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: String) -> Void
    
    func application(_ app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) -> Void
}

@objc(HaloTwoFactorAuthenticationDelegate)
public protocol TwoFactorAuthenticationDelegate {
    
    /// This handler will be called when a push notification coming from the 2-factor authentication process is received
    ///
    /// - Parameters:
    ///   - app: Application receiving the push notification
    ///   - code: Code provided by the server to complete the authentication process
    ///   - notification: Object containing information about the push notification
    func application(_ app: UIApplication, didReceiveTwoFactorAuthCode code: String, remoteNotification notification: HaloNotification) -> Void
    
}
