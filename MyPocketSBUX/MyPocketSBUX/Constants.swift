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

// MARK:- TastingLog Class
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

// MARK:- Order Class
// Class key
let orderClassKey = "Order"

// Field keys
let orderIdKey                      = "id"
let orderStoreIdKey                 = "storeId"
let orderTaxExcludedTotalPriceKey   = "taxExcludedTotalPrice"
let orderTaxIncludedTotalPriceKey   = "taxIncludedTotalPrice"
let orderRemarksKey                 = "remarks"
let orderNotesKey                   = "notes"
let orderMyPocketIdKey              = "myPocketId"
let orderOrderDetailsKey            = "orderDetails"

// MARK:- OrderDetail Class
// Class key
let orderDetailClassKey = "OrderDetail"

// Field keys
let orderDetailProductJanCodeKey        = "productJanCode"
let orderDetailProductNameKey           = "productName"
let orderDetailSizeKey                  = "size"
let orderDetailHotOrIcedKey             = "hotOrIced"
let orderDetailReusableCupKey           = "reusableCup"
let orderDetailTicketKey                = "ticket"
let orderDetailTaxExcludeTotalPriceKey  = "taxExcludeTotalPrice"
let orderDetailTaxExcludeCustomPriceKey = "taxExcludeCustomPrice"
let orderDetailTotalCalorieKey          = "totalCalorie"
let orderDetailCustomCalorieKey         = "customCalorie"
let orderDetailRemarksKey               = "remarks"
let orderDetailOrderObjectIdKey         = "orderObjectId"
let orderDetailProductIngredientsKey    = "productIngredients"

// MARK:- ProductIngredient Class
// Class key
let productIngredientClassKey = "ProductIngredient"

// Field keys
let productIngredientIsCustomKey            = "isCustom"
let productIngredientNameKey                = "name"
let productIngredientMilkTypeKey            = "milkType"
let productIngredientUnitCalorieKey         = "unitCalorie"
let productIngredientUnitPriceKey           = "unitPrice"
let productIngredientQuantityKey            = "quantity"
let productIngredientEnabledKey             = "enabled"
let productIngredientQuantityTypeKey        = "quantityType"
let productIngredientRemarksKey             = "remarks"
let productIngredientOrderDetailObjectIdKey = "orderDetailObjectId"
