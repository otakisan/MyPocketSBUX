//
//  Constants.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/12/12.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

// MARK:- User Class
// Field keys
let userUsernameKey         = "username"
let userProfilePictureKey   = "profilePicture"
let userDisplayNameKey      = "displayName"
let userIsPrivateAccountKey = "isPrivateAccount"
let userBioKey              = "bio"
let userEmailKey            = "email"

// MARK:- Activity Class
// Class key
let activityClassKey = "Activity"

// Field keys
let activityFromUserKey    = "fromUser"
let activityToUserKey      = "toUser"
let activityTypeKey        = "type"
let activityContentKey     = "content"
let activityTastingLogKey  = "tastingLog"

// Type values
let activityTypeLike       = "like"
let activityTypeFollow     = "follow"
let activityTypeComment    = "comment"
let activityTypeJoined     = "joined"
let activityTypeApprove    = "approve"
let activityTypeDeny       = "deny"

// MARK:- Activity Class
// Class key
let tastingLogClassKey = "TastingLog"

// Field keys
let tastingLogIdKey            = "id"
let tastingLogMyPocketIdKey    = "myPocketId"
let tastingLogOrderObjectIdKey = "orderObjectId"
let tastingLogStoreObjectIdKey = "storeObjectId"
let tastingLogPhotoKey         = "photo"
let tastingLogThumbnailKey     = "thumbnail"
let tastingLogTitleKey         = "title"
let tastingLogUpdatedAtKey     = "updatedAt"