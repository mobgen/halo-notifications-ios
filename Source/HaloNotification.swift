//
//  Notification.swift
//  HaloNotifications
//
//  Created by Santos-Díez, Borja on 06/03/2017.
//  Copyright © 2017 Mobgen Technology. All rights reserved.
//

import Foundation

@objc
public enum HaloNotificationType: Int {
    case normal, silent, twoFactor
}

@objc
public class HaloNotification: NSObject {

    struct Keys {
        static let ScheduleId = "scheduleId"
        static let Title = "title"
        static let Body = "body"
        static let Icon = "icon"
        static let Sound = "sound"
        static let NotificationType = "type"
    }
    
    public internal(set) var scheduleId: String?
    public internal(set) var title: String?
    public internal(set) var body: String?
    public internal(set) var icon: String?
    public internal(set) var sound: String?
    public internal(set) var type: HaloNotificationType
    
    init(userInfo: [AnyHashable: Any]) {
        
        scheduleId = userInfo[Keys.ScheduleId] as? String
        title = userInfo[Keys.Title] as? String
        body = userInfo[Keys.Body] as? String
        icon = userInfo[Keys.Icon] as? String
        sound = userInfo[Keys.Sound] as? String
        type = .normal
        
        if let contentAvailable = userInfo["content_available"] as? Int, contentAvailable == 1 {
            type = .silent
        } else if let notifType = userInfo[Keys.NotificationType] as? String {
            switch notifType.lowercased() {
                case "2_factor":
                type = .twoFactor
                default:
                break
            }
        }
        
        super.init()
    }
    
}
