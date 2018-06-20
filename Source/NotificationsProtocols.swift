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
    @objc optional
    func application(_ app: UIApplication, didReceiveRemoteNotification notification: HaloNotification, userInteraction user: Bool, fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)?) -> Void
    
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    @available(iOS 10.0, *)
    @objc optional
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void)
    
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    @available(iOS 10.0, *)
    @objc optional
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void)
}

@objc(HaloTwoFactorAuthenticationDelegate)
public protocol TwoFactorAuthenticationDelegate {
    
    /// This handler will be called when a push notification coming from the 2-factor authentication process is received
    ///
    /// - Parameters:
    ///   - app: Application receiving the push notification
    ///   - code: Code provided by the server to complete the authentication process
    ///   - notification: Object containing information about the push notification
    func application(_ app: UIApplication?, didReceiveTwoFactorAuthCode code: String, remoteNotification notification: HaloNotification) -> Void
    
}
