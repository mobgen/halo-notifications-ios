//
//  HaloNotificationService.swift
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 13/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import UserNotifications

@available(iOSApplicationExtension 10.0, *)
fileprivate extension UNNotificationAttachment {
    static func create(fromMedia media: String, withData data: Data) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileIdentifier = media.components(separatedBy: "/").last!
            let fileURL = tmpSubFolderURL.appendingPathComponent(fileIdentifier)
            
            try data.write(to: fileURL)
            return self.create(fileIdentifier: fileIdentifier, fileUrl: fileURL)
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
    
    static func create(fileIdentifier: String, fileUrl: URL, options: [String : Any]? = nil) -> UNNotificationAttachment? {
        var n: UNNotificationAttachment?
        do {
            n = try UNNotificationAttachment(identifier: fileIdentifier, url: fileUrl, options: options)
        } catch {
            print("error " + error.localizedDescription)
        }
        return n
    }
}

private func resourceURL(forUrlString urlString: String) -> URL? {
    return URL(string: urlString)
}

@available(iOSApplicationExtension 10.0, *)
fileprivate func loadAttachment(forMedia media: String, completionHandler: ((UNNotificationAttachment?) -> Void)) {
    guard let url = resourceURL(forUrlString: media) else {
        completionHandler(nil)
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        if let attachment = UNNotificationAttachment.create(fromMedia: media, withData: data) {
            completionHandler(attachment)
            return
        }
        completionHandler(nil)
    } catch {
        print("error " + error.localizedDescription)
        completionHandler(nil)
    }
}

@available(iOS 10.0, *)
open class HaloNotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let content = bestAttemptContent,
            let imageString = content.userInfo["image"] as? String,
            let imageData = imageString.data(using: .utf8),
            let imageObject = try? JSONSerialization.jsonObject(with: imageData, options: .mutableContainers),
            let imageDict = imageObject as? [String: Any?],
            let imageUrlString = imageDict["url"] as? String
        else {
            contentHandler(request.content)
            return
        }
        
        loadAttachment(forMedia: imageUrlString) { attachment in
            
            if let attachment = attachment {
                content.attachments = [attachment]
            }
            contentHandler(content)
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
