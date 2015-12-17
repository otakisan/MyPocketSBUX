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
        let query = PFQuery(className: activityClassKey)
        query.whereKey(activityFromUserKey, equalTo:PFUser.currentUser()!)
        query.whereKey(activityToUserKey, equalTo:user)
        query.whereKey(activityTypeKey, equalTo: activityTypeFollow)
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
            
            let followActivity = PFObject(className: activityClassKey)
            followActivity.setObject(currentUser, forKey: activityFromUserKey)
            followActivity.setObject(user, forKey: activityToUserKey)
            followActivity.setObject(activityTypeFollow, forKey: activityTypeKey)
                
            let followACL = PFACL(user: currentUser)
            followACL.setPublicReadAccess(true)
            followActivity.ACL = followACL
                
            followActivity.saveEventually(completionBlock)
        }
    }
    
    func isFollowerInBackgroundWithBlock(follower : PFUser, target : PFUser, block: PFQueryArrayResultBlock?) {
        let query = PFQuery(className: activityClassKey)
        query.whereKey(activityFromUserKey, equalTo: follower)
        query.whereKey(activityToUserKey, equalTo: target)
        query.whereKey(activityTypeKey, equalTo: activityTypeFollow)
        
        // 非公開アカウントの場合は承認のアクティビティも必要
        if true == target[userIsPrivateAccountKey] as? Bool {
            let acceptQuery = PFQuery(className: activityClassKey)
            acceptQuery.whereKey(activityFromUserKey, equalTo: target)
            acceptQuery.whereKey(activityToUserKey, equalTo: follower)
            acceptQuery.whereKey(activityTypeKey, equalTo: activityTypeApprove)
            query.whereKey(activityFromUserKey, matchesKey: activityToUserKey, inQuery: acceptQuery)
        }
        
        query.findObjectsInBackgroundWithBlock(block)
    }
    
    func approveUserInBackgroundWithBlock(user: PFUser, block: PFBooleanResultBlock?) {
        if let currentUser = PFUser.currentUser() {
            if user.objectId == PFUser.currentUser()?.objectId {
                return
            }
            
            let approveActivity = PFObject(className: activityClassKey)
            approveActivity.setObject(currentUser, forKey: activityFromUserKey)
            approveActivity.setObject(user, forKey: activityToUserKey)
            approveActivity.setObject(activityTypeApprove, forKey:activityTypeKey)
            
            let approveACL = PFACL(user: currentUser)
            approveACL.setPublicReadAccess(true)
            approveActivity.ACL = approveACL
            
            approveActivity.saveInBackgroundWithBlock(block)
        }
    }
    
    func denyUserInBackgroundWithBlock(user: PFUser, block: PFBooleanResultBlock?) {
        if let currentUser = PFUser.currentUser() {
            if user.objectId == PFUser.currentUser()?.objectId {
                return
            }
            
            let approveActivity = PFObject(className: activityClassKey)
            approveActivity.setObject(currentUser, forKey: activityFromUserKey)
            approveActivity.setObject(user, forKey: activityToUserKey)
            approveActivity.setObject(activityTypeDeny, forKey:activityTypeKey)
            
            let approveACL = PFACL(user: currentUser)
            approveACL.setPublicReadAccess(true)
            approveActivity.ACL = approveACL
            
            approveActivity.saveInBackgroundWithBlock(block)
        }
    }
    
    private func countActivityForLogInBackgroundWithBlock(logId : Int, activityType : String, block : (Int, NSError?) -> Void) {
        let tastingLogQuery = PFQuery(className: tastingLogClassKey)
        tastingLogQuery.whereKey(tastingLogIdKey, equalTo: logId)
        
        let toUserQuery = PFUser.query()!
        toUserQuery.whereKey(userUsernameKey, matchesKey: tastingLogMyPocketIdKey, inQuery: tastingLogQuery)
        
        let activityQuery = PFQuery(className: activityClassKey)
        activityQuery.whereKey(activityToUserKey, matchesQuery: toUserQuery)
        activityQuery.whereKey(activityTypeKey, equalTo: activityType)
        activityQuery.whereKey(activityTastingLogKey, matchesQuery: tastingLogQuery)
        
        activityQuery.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            block(Int(count), error)
        }
    }
    
    func hasLikedLogByCurrentUserInBackgroundWithBlock(logId : Int, block : (Bool, NSError?) -> Void){
        self.queryForLikedLogByCurrentUser(logId)?.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
            block(error == nil && count > 0, error)
        })
    }
    
    func countLikeForLogInBackgroundWithBlock(logId : Int, block : (Int, NSError?) -> Void) {
        self.countActivityForLogInBackgroundWithBlock(logId, activityType: activityTypeLike, block: block)
    }
    
    func likeTastingLogInBackgroundWithBlock(logId : Int, block : ((Bool, NSError?) -> Void)?) {
        // TODO: 分岐で外れたところにもコールバックを入れ込むとなると、かなり煩雑になる。対策は？
        if let currentUser = PFUser.currentUser() {
            
            // ログとユーザーが関連づいていないので個別に取得していく
            let tastingLogQuery = PFQuery(className: tastingLogClassKey)
            tastingLogQuery.whereKey(tastingLogIdKey, equalTo: logId)
            tastingLogQuery.getFirstObjectInBackgroundWithBlock({ (pfObject, error) -> Void in
                if let tastingLog = pfObject, let toUserQuery = PFUser.query() {
                    toUserQuery.whereKey(userUsernameKey, equalTo: tastingLog[tastingLogMyPocketIdKey])
                    toUserQuery.getFirstObjectInBackgroundWithBlock({ (pfUser, error) -> Void in
                        if let toUser = pfUser {
                            let followActivity = PFObject(className: activityClassKey)
                            followActivity.setObject(currentUser, forKey:activityFromUserKey)
                            followActivity.setObject(toUser, forKey: activityToUserKey)
                            followActivity.setObject(activityTypeLike, forKey:activityTypeKey)
                            followActivity.setObject(tastingLog, forKey: activityTastingLogKey)
                            
                            let followACL = PFACL(user: currentUser)
                            followACL.setPublicReadAccess(true)
                            followActivity.ACL = followACL
                            
                            followActivity.saveInBackgroundWithBlock(block)
                        }
                    })
                }
            })
        }
    }
    
    func unlikeTastingLogInBackgroundWithBlock(logId : Int, block : ((Bool, NSError?) -> Void)?) {
        self.queryForLikedLogByCurrentUser(logId)?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if let activities = results where activities.count > 0 {
                let totalCount = activities.count
                var processedCount = 0
                var successCount = 0
                results?.forEach({ (activity) -> () in
                    activity.deleteInBackgroundWithBlock({ (isSuccess, error) -> Void in
                        ++processedCount
                        successCount += (isSuccess ? 1 : 0)
                        if totalCount == processedCount {
                            block?(successCount == totalCount, error)
                        }
                    })
                })
            } else {
                block?(results != nil, error)
            }
        })
    }
    
    private func queryForLikedLogByCurrentUser(logId : Int) -> PFQuery? {
        
        var activityQuery : PFQuery?
        if let currentUser = PFUser.currentUser() {
            // TODO: ACLが絡んできたときに、意図した通りに動作するかどうか
            let tastingLogQuery = PFQuery(className: tastingLogClassKey)
            tastingLogQuery.whereKey(tastingLogIdKey, equalTo: logId)
            
            let toUserQuery = PFUser.query()!
            toUserQuery.whereKey(userUsernameKey, matchesKey: tastingLogMyPocketIdKey, inQuery: tastingLogQuery)
            
            activityQuery = PFQuery(className: activityClassKey)
            activityQuery!.whereKey(activityFromUserKey, equalTo: currentUser)
            activityQuery!.whereKey(activityToUserKey, matchesQuery: toUserQuery)
            activityQuery!.whereKey(activityTypeKey, equalTo: activityTypeLike)
            activityQuery!.whereKey(activityTastingLogKey, matchesQuery: tastingLogQuery)
        }
        
        return activityQuery
    }
    
    func countCommentForLogInBackgroundWithBlock(logId : Int, block : (Int, NSError?) -> Void) {
        self.countActivityForLogInBackgroundWithBlock(logId, activityType: activityTypeComment, block: block)
    }

    func commentOnTastingLogInBackgroundWithBlock(logId : Int, comment : String, block : ((Bool, NSError?) -> Void)?) {
        // TODO: 分岐で外れたところにもコールバックを入れ込むとなると、かなり煩雑になる。対策は？
        if let currentUser = PFUser.currentUser() {
            
            // ログとユーザーが関連づいていないので個別に取得していく
            let tastingLogQuery = PFQuery(className: tastingLogClassKey)
            tastingLogQuery.whereKey(tastingLogIdKey, equalTo: logId)
            tastingLogQuery.getFirstObjectInBackgroundWithBlock({ (pfObject, error) -> Void in
                if let tastingLog = pfObject, let toUserQuery = PFUser.query() {
                    toUserQuery.whereKey(userUsernameKey, equalTo: tastingLog[tastingLogMyPocketIdKey])
                    toUserQuery.getFirstObjectInBackgroundWithBlock({ (pfUser, error) -> Void in
                        if let toUser = pfUser {
                            let followActivity = PFObject(className: activityClassKey)
                            followActivity.setObject(currentUser, forKey:activityFromUserKey)
                            followActivity.setObject(toUser, forKey: activityToUserKey)
                            followActivity.setObject(activityTypeComment, forKey:activityTypeKey)
                            followActivity.setObject(tastingLog, forKey: activityTastingLogKey)
                            followActivity.setObject(comment, forKey: activityContentKey)
                            
                            let followACL = PFACL(user: currentUser)
                            followACL.setPublicReadAccess(true)
                            followActivity.ACL = followACL
                            
                            followActivity.saveInBackgroundWithBlock(block)
                        }
                    })
                }
            })
        }
    }
}
