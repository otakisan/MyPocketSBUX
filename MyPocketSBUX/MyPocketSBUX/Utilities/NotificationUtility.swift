//
//  NotificationUtility.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/30.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class NotificationUtility: NSObject {

    static let instance = BaseFactory.instance.createNotificationUtility()
    
    func localNotificationNow(message : String) {
        // 通知の許可を得ている前提
        
        // 設定する前に、設定済みの通知をキャンセルする
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // 設定し直す
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        localNotification.alertBody = message
        localNotification.timeZone = NSTimeZone.localTimeZone()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
    }
    
    func pushNotificationUserDidLogIn() {
    }
}
