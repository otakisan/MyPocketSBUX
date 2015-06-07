//
//  TastingLogs.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/05/05.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class TastingLogs: DbContextBase {
    static var contextInstance : TastingLogs = TastingLogs()
    
    class func instance() -> TastingLogs{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "TastingLog"
    }
        
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        
        for newData in jsonObject {
            var entity : TastingLog = TastingLogs.instance().createEntity()
            entity.id = (newData["id"] as? NSNumber) ?? 0
            entity.tag = ((newData["tag"] as? NSString) ?? "") as String
            entity.title = ((newData["title"] as? NSString) ?? "") as String
            entity.tastingAt = DateUtility.dateFromSqliteDateTimeString(newData as! NSDictionary, key: "tasting_at")
            entity.detail = ((newData["detail"] as? NSString) ?? "") as String
            entity.myPocketId = ((newData["my_pocket_id"] as? NSString) ?? "") as String
            entity.createdAt = DateUtility.dateFromSqliteDateTimeString(newData as! NSDictionary, key: "created_at")
            entity.updatedAt = DateUtility.dateFromSqliteDateTimeString(newData as! NSDictionary, key: "updated_at")
            
            // 先に登録して、ManagedObjectContext配下に置かないとリレーション設定の際にエラーになる
            // （不正なコンテキスト、というエラー）
            TastingLogs.registerEntity(entity)
            if let store : Store = Stores.instance().findById(Int((newData["store_id"] as? NSNumber) ?? 0)) {
                entity.store = store
            }
            if let order : Order = Orders.instance().findById(Int((newData["order_id"] as? NSNumber) ?? 0)) {
                entity.order = order
            }
            
            TastingLogs.insertEntity(entity)
        }
    }

}
