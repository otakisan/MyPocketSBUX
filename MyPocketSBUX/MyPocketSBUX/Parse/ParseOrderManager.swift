//
//  ParseOrderManager.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/09/27.
//  Copyright © 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import Parse

class ParseOrderManager: OrderManager {
    
    override func postJsonContentsToWeb(order: Order) -> Bool {
        if IdentityContext.sharedInstance.signedIn() {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                do {
                    let pfOrder = PFObject(className: orderClassKey)
                    pfOrder[orderIdKey] = order.id
                    pfOrder[orderStoreIdKey] = order.storeId
                    pfOrder[orderTaxExcludedTotalPriceKey] = order.taxExcludedTotalPrice
                    pfOrder[orderTaxIncludedTotalPriceKey] = order.taxIncludedTotalPrice
                    pfOrder[orderRemarksKey] = order.remarks
                    pfOrder[orderNotesKey] = order.notes
                    pfOrder[orderMyPocketIdKey] = order.myPocketId
                    try pfOrder.save() // 一旦saveする必要があるらしい。
                    // PFRelation.addObject時に実際に保存されている必要があり、saveEventuallyだとうまく動作しない。
                    //pfOrder.saveEventually()
                    
                    let orderDetailsRelation = pfOrder.relationForKey(orderOrderDetailsKey)
                    try order.orderDetails.forEach({ (element) -> () in
                        if let orderdetail = element as? OrderDetail {
                            let pfOrderDetail = PFObject(className: orderDetailClassKey)
                            pfOrderDetail[orderDetailProductJanCodeKey] = orderdetail.productJanCode
                            pfOrderDetail[orderDetailProductNameKey] = orderdetail.productName
                            pfOrderDetail[orderDetailSizeKey] = orderdetail.size
                            pfOrderDetail[orderDetailHotOrIcedKey] = orderdetail.hotOrIced
                            pfOrderDetail[orderDetailReusableCupKey] = orderdetail.reusableCup
                            pfOrderDetail[orderDetailTicketKey] = orderdetail.ticket
                            pfOrderDetail[orderDetailTaxExcludeTotalPriceKey] = orderdetail.taxExcludeTotalPrice
                            pfOrderDetail[orderDetailTaxExcludeCustomPriceKey] = orderdetail.taxExcludeCustomPrice
                            pfOrderDetail[orderDetailTotalCalorieKey] = orderdetail.totalCalorie
                            pfOrderDetail[orderDetailCustomCalorieKey] = orderdetail.customCalorie
                            pfOrderDetail[orderDetailRemarksKey] = orderdetail.remarks
                            try pfOrderDetail.save()
                            //pfOrderDetail.saveEventually()
                            
                            pfOrderDetail[orderDetailOrderObjectIdKey] = pfOrder
                            orderDetailsRelation.addObject(pfOrderDetail)
                            
                            let productIngredientsRelation = pfOrderDetail.relationForKey(orderDetailProductIngredientsKey)
                            try orderdetail.productIngredients.forEach({ (elementPI) -> () in
                                if let productIngredient = elementPI as? ProductIngredient {
                                    let pfProductIngredient = PFObject(className: productIngredientClassKey)
                                    pfProductIngredient[productIngredientIsCustomKey] = productIngredient.isCustom
                                    pfProductIngredient[productIngredientNameKey] = productIngredient.name
                                    pfProductIngredient[productIngredientMilkTypeKey] = productIngredient.milkType
                                    pfProductIngredient[productIngredientUnitCalorieKey] = productIngredient.unitCalorie
                                    pfProductIngredient[productIngredientUnitPriceKey] = productIngredient.unitPrice
                                    pfProductIngredient[productIngredientQuantityKey] = productIngredient.quantity
                                    pfProductIngredient[productIngredientEnabledKey] = productIngredient.enabled
                                    pfProductIngredient[productIngredientQuantityTypeKey] = productIngredient.quantityType
                                    pfProductIngredient[productIngredientRemarksKey] = productIngredient.remarks
                                    try pfProductIngredient.save() // Pointerを設定する前に保存する必要がある
                                    //pfProductIngredient.saveEventually()
                                    
                                    pfProductIngredient[productIngredientOrderDetailObjectIdKey] = pfOrderDetail
                                    try pfProductIngredient.save() // 値の設定を完了したので保存
                                    productIngredientsRelation.addObject(pfProductIngredient)
                                }
                            })
                            
                            try pfOrderDetail.save()
                            //pfOrderDetail.saveEventually()
                        }
                    })
                    
                    try pfOrder.save()
                    //pfOrder.saveEventually()
                    
                }catch{
                    
                    NotificationUtility.instance.localNotificationNow("save again order. : \(order.notes)")
                }
            }
            
            return true
        }else{
            return false
        }
    }
        
    override func nextOrderId() -> Int {
        return ContentsManager.instance.nextId(Orders.instance().entityName())
    }
    
    override func nextOrderDetailId() -> Int {
        return ContentsManager.instance.nextId(OrderDetails.instance().entityName())
    }
    
    override func nextProductIngredientId() -> Int {
        return ContentsManager.instance.nextId(ProductIngredients.instance().entityName())
    }
    
//    private func insertEntityIntoLocalDb(jsonObject : [PFObject]) {
//        
//        for newData in jsonObject {
//            let entity : Order = Orders.instance().createEntity()
//            entity.id = (newData["id"] as? NSNumber) ?? 0
//            entity.taxExcludedTotalPrice = (newData["tax_excluded_total_price"] as? NSNumber) ?? 0
//            entity.taxIncludedTotalPrice = (newData["tax_included_total_price"] as? NSNumber) ?? 0
//            entity.remarks = ((newData["remarks"] as? NSString) ?? "") as String
//            entity.notes = ((newData["notes"] as? NSString) ?? "") as String
//            entity.myPocketId = ((newData["my_pocket_id"] as? NSString) ?? "") as String
//            entity.createdAt = DateUtility.dateFromSqliteDateTimeString(newData as! NSDictionary, key: "created_at")
//            entity.updatedAt = DateUtility.dateFromSqliteDateTimeString(newData as! NSDictionary, key: "updated_at")
//            
//            // 先に登録して、ManagedObjectContext配下に置かないとリレーション設定の際にエラーになる
//            // （不正なコンテキスト、というエラー）
//            Orders.registerEntity(entity)
//            
//            for childData in newData["order_details"] as! NSArray {
//                let childEntity : OrderDetail = OrderDetails.instance().createEntity()
//                childEntity.id = (childData["id"] as? NSNumber) ?? 0
//                childEntity.productJanCode = ((childData["product_jan_code"] as? NSString) ?? "") as String
//                childEntity.productName = ((childData["product_name"] as? NSString) ?? "") as String
//                childEntity.size = ((childData["size"] as? NSString) ?? "") as String
//                childEntity.hotOrIced = ((childData["hot_or_iced"] as? NSString) ?? "") as String
//                childEntity.reusableCup = (childData["reusable_cup"] as? NSNumber) ?? 0
//                childEntity.ticket = ((childData["ticket"] as? NSString) ?? "") as String
//                childEntity.taxExcludeTotalPrice = (childData["tax_exclude_total_price"] as? NSNumber) ?? 0
//                childEntity.taxExcludeCustomPrice = (childData["tax_exclude_custom_price"] as? NSNumber) ?? 0
//                childEntity.totalCalorie = (childData["total_calorie"] as? NSNumber) ?? 0
//                childEntity.customCalorie = (childData["custom_calorie"] as? NSNumber) ?? 0
//                childEntity.remarks = ((childData["remarks"] as? NSString) ?? "") as String
//                childEntity.createdAt = DateUtility.dateFromSqliteDateTimeString(childData as! NSDictionary, key: "created_at")
//                childEntity.updatedAt = DateUtility.dateFromSqliteDateTimeString(childData as! NSDictionary, key: "updated_at")
//                
//                OrderDetails.registerEntity(childEntity)
//                childEntity.order = entity
//                
//                for grandChildData in childData["product_ingredients"] as! NSArray {
//                    let grandChildEntity : ProductIngredient = ProductIngredients.instance().createEntity()
//                    grandChildEntity.id = (grandChildData["id"] as? NSNumber) ?? 0
//                    grandChildEntity.isCustom = (grandChildData["is_custom"] as? NSNumber) ?? 0
//                    grandChildEntity.name = ((grandChildData["name"] as? NSString) ?? "") as String
//                    grandChildEntity.milkType = ((grandChildData["milk_type"] as? NSString) ?? "") as String
//                    grandChildEntity.unitCalorie = (grandChildData["unit_calorie"] as? NSNumber) ?? 0
//                    grandChildEntity.unitPrice = (grandChildData["unit_price"] as? NSNumber) ?? 0
//                    grandChildEntity.quantity = (grandChildData["quantity"] as? NSNumber) ?? 0
//                    grandChildEntity.enabled = (grandChildData["enabled"] as? NSNumber) ?? 0
//                    grandChildEntity.quantityType = (grandChildData["quantity_type"] as? NSNumber) ?? 0
//                    grandChildEntity.remarks = ((grandChildData["remarks"] as? NSString) ?? "") as String
//                    grandChildEntity.createdAt = DateUtility.dateFromSqliteDateTimeString(grandChildData as! NSDictionary, key: "created_at")
//                    grandChildEntity.updatedAt = DateUtility.dateFromSqliteDateTimeString(grandChildData as! NSDictionary, key: "updated_at")
//                    
//                    ProductIngredients.registerEntity(grandChildEntity)
//                    grandChildEntity.orderDetail = childEntity
//                    
//                    ProductIngredients.insertEntity(grandChildEntity)
//                }
//                
//                OrderDetails.insertEntity(childEntity)
//            }
//            
//            // TODO: 店舗ID、どうするか
//            if let store : Store = Stores.findByStoreId(Int((newData["store_id"] as? NSNumber) ?? 0)) {
//                entity.storeId = store.storeId
//            }
//            
//            Orders.insertEntity(entity)
//        }
//    }

}
