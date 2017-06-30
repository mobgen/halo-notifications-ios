//
//  HaloNotificationServiceExtensionObjC.m
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 30/06/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

#import "HaloNotificationServiceExtensionObjC.h"
#import <HaloNotifications/HaloNotifications-Swift.h>

@interface HaloNotificationServiceExtensionObjC ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation HaloNotificationServiceExtensionObjC

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    [NotificationsUtils didReceive:request withContent:self.bestAttemptContent contentHandler:contentHandler delegate:self];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [NotificationsUtils urlSession:session downloadTask:downloadTask didFinishDownloadingTo:location content:self.bestAttemptContent contentHandler:self.contentHandler];
}

@end
