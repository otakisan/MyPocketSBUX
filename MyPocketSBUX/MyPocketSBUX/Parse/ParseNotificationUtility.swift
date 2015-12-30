//
//  ParseNotificationUtility.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/30.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse

class ParseNotificationUtility: NotificationUtility {
    override func pushNotificationUserDidLogIn() {
        PFInstallation.currentInstallation().saveInBackgroundWithBlock({ (succeeded, error) -> Void in
            if let query = PFInstallation.query(), let currentUser = PFUser.currentUser() {
                let push = PFPush()
                // TODO: カレントユーザーと関係のあるユーザーにのみ通知するようにする
                query.whereKey("user", notEqualTo: currentUser)
                push.setQuery(query)
                push.setMessage("\(IdentityContext.sharedInstance.currentUserID) signed in!")
                push.sendPushInBackground()
            }
        })
    }
}
