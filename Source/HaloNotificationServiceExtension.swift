//
//  HaloNotificationService.swift
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 13/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import UserNotifications

@available(iOS 10.0, *)
open class HaloNotificationServiceExtension: UNNotificationServiceExtension, URLSessionDownloadDelegate {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        NotificationsUtils.didReceive(request, withContent: bestAttemptContent, contentHandler: contentHandler, delegate: self)
    }
    
    override open func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler,
            let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    // MARK: URLSessionDownloadDelegate methods
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        NotificationsUtils.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location, content: self.bestAttemptContent, contentHandler: self.contentHandler)
        
    }
    
}


