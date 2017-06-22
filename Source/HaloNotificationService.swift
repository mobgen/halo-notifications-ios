//
//  HaloNotificationService.swift
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 13/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import UserNotifications

@available(iOS 10.0, *)
open class HaloNotificationService: UNNotificationServiceExtension, URLSessionDownloadDelegate {
    
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
        
        loadAttachment(forMedia: imageUrlString)
        
    }
    
    override open func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler,
            let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    // MARK: Private utility functions
    
    fileprivate func storeFile(temporaryLocation location: URL, withFilename filename: String) -> URL? {
        
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let newFileURL = tmpSubFolderURL.appendingPathComponent(filename)
            
            try fileManager.copyItem(atPath: location.relativePath, toPath: newFileURL.relativePath)
            
            return newFileURL
        } catch {
            print("error " + error.localizedDescription)
        }
        
        return nil
    }
    
    fileprivate func loadAttachment(forMedia media: String) {
        
        guard let url = URL(string: media) else {
            print("Error generating download URL")
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: "imageDownload"), delegate: self, delegateQueue: nil)
        
        // Create the task to download the file
        let task = session.downloadTask(with: url)
        task.resume()
    }

    // MARK: URLSessionDownloadDelegate methods

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let contentHandler = contentHandler,
            let content = bestAttemptContent else {
                print("No content or content handler available")
                return
        }
        
        guard let response = downloadTask.response else {
            print("No response from the download task")
            contentHandler(content)
            return
        }
        
        let filename = response.suggestedFilename ?? "image.jpg"
        
        // Copy the temporary file to a disk location and create the UNNotificationAttachment from it
        if let fileURL = self.storeFile(temporaryLocation: location, withFilename: filename),
            let attachment = try? UNNotificationAttachment(identifier: filename, url: fileURL) {
            
            content.attachments = [attachment]
            contentHandler(content)
            return
        }
        
    }
    
    
}
