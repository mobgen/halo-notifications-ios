//
//  NotificationsAddon+ServiceExtension.swift
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 01/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import UserNotifications

@available(iOS 10.0, *)
extension NotificationsAddon {
    
public func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    
        if let bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent,
            let data = request.content.userInfo["data"] as? [String: Any],
            let image = data["image"] as? [String: String],
            let imageUrl = image["url"],
            let url = URL(string: imageUrl)
        {
            // Modify the notification content here...
            if let attachment = try? UNNotificationAttachment(identifier: "image", url: url) {
                bestAttemptContent.attachments = [attachment]
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    public func serviceExtensionTimeWillExpire(bestAttemptContent: UNMutableNotificationContent?, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) -> Void {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
