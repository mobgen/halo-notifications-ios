//
//  NotificationService.swift
//  HaloRichNotifications
//
//  Created by Santos-Díez, Borja on 01/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent,
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
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
