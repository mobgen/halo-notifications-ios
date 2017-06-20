//
//  HaloNotificationService.swift
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 13/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import Foundation
import Halo
import UserNotifications

@available(iOS 10.0, *)
open class HaloNotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent,
            let imageString = bestAttemptContent.userInfo["image"] as? String,
            let imageData = imageString.data(using: .utf8),
            let imageDict = try? JSONSerialization.jsonObject(with: imageData, options: .mutableContainers)
        {
            if let imageDict = imageDict as? [String: Any?],
                let imageUrlString = imageDict["url"] as? String,
                let imageUrl = URL(string: imageUrlString),
                let imageData = try? Data(contentsOf: imageUrl),
                let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.jpg", data: imageData) {
                
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

@available(iOSApplicationExtension 10.0, *)
extension UNNotificationAttachment {
    
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: Data, options: [NSObject : AnyObject]? = nil) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
            try data.write(to: fileURL!, options: [])
            let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL!, options: options)
            return imageAttachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}
