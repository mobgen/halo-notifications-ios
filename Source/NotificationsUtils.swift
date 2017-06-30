//
//  UtilityFunctions.swift
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 30/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import Foundation

// MARK: Utility functions

@available(iOSApplicationExtension 10.0, *)
class NotificationsUtils: NSObject {
    
    class func didReceive(_ request: UNNotificationRequest, withContent content: UNMutableNotificationContent?, contentHandler: @escaping (UNNotificationContent) -> Void, delegate: URLSessionDownloadDelegate) {
        
        guard let content = content,
            let imageString = content.userInfo["image"] as? String,
            let imageData = imageString.data(using: .utf8),
            let imageObject = try? JSONSerialization.jsonObject(with: imageData, options: .mutableContainers),
            let imageDict = imageObject as? [String: Any?],
            let imageUrlString = imageDict["url"] as? String
            else {
                contentHandler(request.content)
                return
        }
        
        self.loadAttachment(forMedia: imageUrlString, delegate: delegate)
        
    }
    
    class func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL, content: UNMutableNotificationContent?, contentHandler:  ((UNNotificationContent) -> Void)?) {
        
        guard let contentHandler = contentHandler,
            let content = content else {
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
    
    class func storeFile(temporaryLocation location: URL, withFilename filename: String) -> URL? {
        
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
    
    class func loadAttachment(forMedia media: String, delegate: URLSessionDownloadDelegate) {
        
        guard let url = URL(string: media) else {
            print("Error generating download URL")
            return
        }
        
        let config = URLSessionConfiguration.background(withIdentifier: ProcessInfo.processInfo.globallyUniqueString)
        config.sharedContainerIdentifier = "group.com.mobgen.halo"
        
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
        
        // Create the task to download the file
        let task = session.downloadTask(with: url)
        task.resume()
    }
}
