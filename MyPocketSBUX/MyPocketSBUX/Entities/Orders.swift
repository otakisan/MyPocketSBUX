//
//  Orders.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/29.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Orders: DbContextBase {
    static var contextInstance : Orders = Orders()
    
    class func instance() -> Orders{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Order"
    }
    
    class func sequenceNumber() -> Int {
        // TODO: IDの採番
        return Orders.instance().maxId() + 1
        //return Int(Double(NSDate().timeIntervalSince1970) * 1.0e6)
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        
        for newData in jsonObject {
            let entity : Order = Orders.instance().createEntity()
            entity.id = (newData["id"] as? NSNumber) ?? 0
            entity.taxExcludedTotalPrice = (newData["tax_excluded_total_price"] as? NSNumber) ?? 0
            entity.taxIncludedTotalPrice = (newData["tax_included_total_price"] as? NSNumber) ?? 0
            entity.remarks = ((newData["remarks"] as? NSString) ?? "") as String
            entity.notes = ((newData["notes"] as? NSString) ?? "") as String
            entity.myPocketId = ((newData["my_pocket_id"] as? NSString) ?? "") as String
            entity.createdAt = DateUtility.dateFromSqliteDateTimeString(newData as! NSDictionary, key: "created_at")
            entity.updatedAt = DateUtility.dateFromSqliteDateTimeString(newData as! NSDictionary, key: "updated_at")
            
            // 先に登録して、ManagedObjectContext配下に置かないとリレーション設定の際にエラーになる
            // （不正なコンテキスト、というエラー）
            Orders.registerEntity(entity)
            
            for childData in newData["order_details"] as! NSArray {
                let childEntity : OrderDetail = OrderDetails.instance().createEntity()
                childEntity.id = (childData["id"] as? NSNumber) ?? 0
                childEntity.productJanCode = ((childData["product_jan_code"] as? NSString) ?? "") as String
                childEntity.productName = ((childData["product_name"] as? NSString) ?? "") as String
                childEntity.size = ((childData["size"] as? NSString) ?? "") as String
                childEntity.hotOrIced = ((childData["hot_or_iced"] as? NSString) ?? "") as String
                childEntity.reusableCup = (childData["reusable_cup"] as? NSNumber) ?? 0
                childEntity.ticket = ((childData["ticket"] as? NSString) ?? "") as String
                childEntity.taxExcludeTotalPrice = (childData["tax_exclude_total_price"] as? NSNumber) ?? 0
                childEntity.taxExcludeCustomPrice = (childData["tax_exclude_custom_price"] as? NSNumber) ?? 0
                childEntity.totalCalorie = (childData["total_calorie"] as? NSNumber) ?? 0
                childEntity.customCalorie = (childData["custom_calorie"] as? NSNumber) ?? 0
                childEntity.remarks = ((childData["remarks"] as? NSString) ?? "") as String
                childEntity.createdAt = DateUtility.dateFromSqliteDateTimeString(childData as! NSDictionary, key: "created_at")
                childEntity.updatedAt = DateUtility.dateFromSqliteDateTimeString(childData as! NSDictionary, key: "updated_at")

                OrderDetails.registerEntity(childEntity)
                childEntity.order = entity
            
                for grandChildData in childData["product_ingredients"] as! NSArray {
                    let grandChildEntity : ProductIngredient = ProductIngredients.instance().createEntity()
                    grandChildEntity.id = (grandChildData["id"] as? NSNumber) ?? 0
                    grandChildEntity.isCustom = (grandChildData["is_custom"] as? NSNumber) ?? 0
                    grandChildEntity.name = ((grandChildData["name"] as? NSString) ?? "") as String
                    grandChildEntity.milkType = ((grandChildData["milk_type"] as? NSString) ?? "") as String
                    grandChildEntity.unitCalorie = (grandChildData["unit_calorie"] as? NSNumber) ?? 0
                    grandChildEntity.unitPrice = (grandChildData["unit_price"] as? NSNumber) ?? 0
                    grandChildEntity.quantity = (grandChildData["quantity"] as? NSNumber) ?? 0
                    grandChildEntity.enabled = (grandChildData["enabled"] as? NSNumber) ?? 0
                    grandChildEntity.quantityType = (grandChildData["quantity_type"] as? NSNumber) ?? 0
                    grandChildEntity.remarks = ((grandChildData["remarks"] as? NSString) ?? "") as String
                    grandChildEntity.createdAt = DateUtility.dateFromSqliteDateTimeString(grandChildData as! NSDictionary, key: "created_at")
                    grandChildEntity.updatedAt = DateUtility.dateFromSqliteDateTimeString(grandChildData as! NSDictionary, key: "updated_at")
                    
                    ProductIngredients.registerEntity(grandChildEntity)
                    grandChildEntity.orderDetail = childEntity
                    
                    ProductIngredients.insertEntity(grandChildEntity)
                }
                
                OrderDetails.insertEntity(childEntity)
            }
            
            // TODO: 店舗ID、どうするか
            if let store : Store = Stores.findByStoreId(Int((newData["store_id"] as? NSNumber) ?? 0)) {
                entity.storeId = store.storeId
            }
            
            Orders.insertEntity(entity)
        }
    }

}
