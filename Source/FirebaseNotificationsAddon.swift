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
import HaloNotifications.Firebase

@objc(HaloFirebaseNotificationsAddon)
open class FirebaseNotificationsAddon: NSObject, HaloNotificationsAddon, HaloLifecycleAddon, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    public var completionHandler: ((HaloAddon, Bool) -> Void)?
    public var addonName = "Notifications"
    public var delegate: NotificationsDelegate?
    public var twoFactorDelegate: TwoFactorAuthenticationDelegate?
    public var notificationEvents : Bool = false

    fileprivate var autoRegister: Bool = true
    open var token: String?

    public init(autoRegister auto: Bool = true) {
        super.init()
        self.autoRegister = auto
    }
    
    // MARK: Addon lifecycle

    open func setup(haloCore core: CoreManager, completionHandler handler: ((HaloAddon, Bool) -> Void)? = nil) {
        handler?(self, true)
    }

    open func startup(app: UIApplication, haloCore core: CoreManager, completionHandler handler: ((HaloAddon, Bool) -> Void)? = nil) {
        
        if FirebaseApp.app() == nil {
            
            if let path = Bundle.main.path(forResource: Manager.core.configuration, ofType: "plist"),
                let data = NSDictionary(contentsOfFile: path),
                let firebasePlistName = data[CoreConstants.firebasePlistName] as? String,
                let firebaseConfigFile = Bundle.main.path(forResource: firebasePlistName, ofType: "plist"),
                let firebaseOptions = FirebaseOptions(contentsOfFile: firebaseConfigFile) {
                
                FirebaseApp.configure(options: firebaseOptions)
            
            } else {
               
                FirebaseApp.configure()
            }
        }

        self.completionHandler = handler
        Messaging.messaging().delegate = self

        
        if self.autoRegister {
            registerApplicationForNotifications(app)
        } else {
            handler?(self, true)
        }
    }
    
    @available(iOSApplicationExtension 10.0, *)
    public func enableNotificationEvents(userNotificationCenter : UNUserNotificationCenter , notificationCategory : String){
        // For iOS 10 display notification (sent via APNS)
        let generalCategory = UNNotificationCategory(identifier: notificationCategory,
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: [.customDismissAction])
        userNotificationCenter.setNotificationCategories([generalCategory])
        notificationEvents = true
        UNUserNotificationCenter.current().delegate = self
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
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(
            options: options,
            completionHandler: {_, _ in })
        
        app.registerForRemoteNotifications()
        
    }
    
    @available(iOS, obsoleted: 10.0)
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
    public func applicationDidFinishLaunching(_ app: UIApplication, core: CoreManager, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
        }
        
        return true
    }
    
    public func applicationDidBecomeActive(_ app: UIApplication, core: CoreManager) {
        
    }
    
    public func applicationDidEnterBackground(_ app: UIApplication, core: CoreManager) {
        
    }
    
    public func applicationWillChangeEnvironment(_ app: UIApplication, core: CoreManager) {
        DispatchQueue.main.async {
             app.unregisterForRemoteNotifications()
        }
    }
    
    public func applicationDidChangeEnvironment(_ app: UIApplication, core: CoreManager) {
    }
    
    // MARK: Notifications
    open func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data, core: CoreManager) {
        core.logMessage("Registered for remote notifications with token \(deviceToken.description)", level: .info)
        updateToken(fcmToken: Messaging.messaging().fcmToken)
        self.completionHandler?(self, true)
    }

    open func application(_ app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError, core: CoreManager) {
        core.logMessage("Error registering for remote notifications. \(error.localizedDescription)", level: .error)
        
        #if targetEnvironment(simulator)
            self.completionHandler?(self, true)
        #else
            self.completionHandler?(self, false)
        #endif
    }
    
    
    
    @objc
    open func application(_ app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], core: CoreManager, userInteraction user: Bool, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        func checkTwoFactorAndNotify(notification: HaloNotification,app: UIApplication,user:Bool,completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
            if notification.type == .twoFactor {
                if let code = notification.payload["code"] as? String {
                    self.twoFactorDelegate?.application(app, didReceiveTwoFactorAuthCode: code, remoteNotification: notification)
                } else {
                    Manager.core.logMessage("No 'code' field was found within the payload", level: .error)
                }
            }
            self.delegate?.application?(app, didReceiveRemoteNotification: notification, userInteraction: user, fetchCompletionHandler: completionHandler)
        }
        
        let notification = HaloNotification(userInfo: userInfo)
        guard let deviceAlias = core.device?.alias else {
            checkTwoFactorAndNotify(notification: notification,app: app, user: user, completionHandler: completionHandler)
            return
        }
        guard let scheduleId = userInfo["scheduleId"] as! String? else {
            checkTwoFactorAndNotify(notification: notification,app: app, user: user, completionHandler: completionHandler)
            return
        }
        
        if(notificationEvents){
            let haloNotificationEvent : HaloNotificationEvent = HaloNotificationEvent(device: deviceAlias, schedule: scheduleId, action: EventType.receipt.rawValue)
            core.notificationAction(notificationEvent: haloNotificationEvent, completionHandler: { (event, error) in
                checkTwoFactorAndNotify(notification: notification, app: app, user: user, completionHandler: completionHandler)
            })
        } else {
            checkTwoFactorAndNotify(notification: notification,app: app, user: user, completionHandler: completionHandler)
        }
    }
    
    @available(iOS 10.0, *)
    open func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, core: CoreManager,fetchCompletionHandler completionHandler: @escaping () -> Void) {
        
        guard let deviceAlias = core.device?.alias else {
            delegate?.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
            return
        }
        
        guard let scheduleId = response.notification.request.content.userInfo["scheduleId"] as! String? else {
            delegate?.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
            return
        }
        
        if(notificationEvents){
            var  haloNotificationEvent : HaloNotificationEvent?
            if(response.actionIdentifier ==  UNNotificationDismissActionIdentifier ) {
                haloNotificationEvent = HaloNotificationEvent(device:  deviceAlias, schedule: scheduleId, action: EventType.dismiss.rawValue)
            } else if(response.actionIdentifier == UNNotificationDefaultActionIdentifier){
                haloNotificationEvent = HaloNotificationEvent(device:  deviceAlias, schedule: scheduleId, action: EventType.open.rawValue)
            }
            if let actionEvent = haloNotificationEvent {
                core.notificationAction(notificationEvent: actionEvent, completionHandler: { [unowned self] (event, error) in
                    self.delegate?.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
                })
            }
        } else {
            self.delegate?.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
        }
    }
    
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        func checkTwoFactorAndNotify(notification haloNotification: HaloNotification,center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            if haloNotification.type == .twoFactor {
                if let code = haloNotification.payload["code"] as? String {
                    self.twoFactorDelegate?.application(nil, didReceiveTwoFactorAuthCode: code, remoteNotification: haloNotification)
                } else {
                    Manager.core.logMessage("No 'code' field was found within the payload", level: .error)
                }
                
            }
            self.delegate?.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
        }
        
        let haloNotification = HaloNotification(unNotification:notification)
        checkTwoFactorAndNotify(notification: haloNotification, center: center, willPresent: notification, withCompletionHandler: completionHandler)
        
    }

    @objc
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        Manager.core.logMessage("Did refresh Firebase token: \(fcmToken)", level: .info)
        updateToken(fcmToken: fcmToken)
    }

    private func updateToken(fcmToken: String?) {
        if let device = Halo.Manager.core.device,
            let token = fcmToken {
            print("[FCMTOKEN]: \(token)")
            device.info = DeviceInfo(platform: "ios", token: token)

            Manager.core.saveDevice { _, result in

                switch result {
                case .success(_, _):
                    Manager.core.logMessage("Successfully registered for remote notifications with Firebase token: \(token)", level: .info)
                    self.completionHandler?(self, true)
                case .failure(let error):
                    Manager.core.logMessage("Error saving device: \(error.localizedDescription)", level: .error)
                    self.completionHandler?(self, false)
                }
            }
        }
    }
}
