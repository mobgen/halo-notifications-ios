//
//  HaloNotificationService.swift
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 13/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
open class HaloNotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent,
            let image = request.content.userInfo["image"] as? [String: String],
            let imageUrl = image["url"],
            let url = URL(string: imageUrl)
        {
            // Modify the notification content here...
            if let attachment = try? UNNotificationAttachment(identifier: "image", url: url) {
                bestAttemptContent.attachments = [attachment]
            }
            
            contentHandler(bestAttemptContent)
        } else {
            // Otherwise, return the original content
            contentHandler(request.content)
        }
    }
    
    override open func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
