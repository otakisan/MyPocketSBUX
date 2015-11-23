//
//  ParseUtility.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/11/15.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse

class ParseUtility: NSObject {
    static let instance = ParseUtility()

    func unfollowUserEventually(user : PFUser) {
        let query = PFQuery(className: "Activity")
        query.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        query.whereKey("toUser", equalTo:user)
        query.whereKey("type", equalTo:"follow")
        query.findObjectsInBackgroundWithBlock { (followActivities, error) -> Void in
            // While normally there should only be one follow activity returned, we can't guarantee that.
            if error == nil, let activities = followActivities {
                for followActivity in activities {
                    followActivity.deleteEventually()
                }
            }
        }
    }
    
    func followUserEventually(user: PFUser, completionBlock: (succeeded:Bool, error : NSError?) -> Void) {
        if let currentUser = PFUser.currentUser() {
            if user.objectId == PFUser.currentUser()?.objectId {
                return
            }
            
            let followActivity = PFObject(className: "Activity")
            followActivity.setObject(currentUser, forKey:"fromUser")
            followActivity.setObject(user, forKey:"toUser")
            followActivity.setObject("follow", forKey:"type")
                
            let followACL = PFACL(user: currentUser)
            followACL.setPublicReadAccess(true)
            followActivity.ACL = followACL
                
            followActivity.saveEventually(completionBlock)
        }
    }
}
