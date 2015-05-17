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
            entity.title = ((newData["title"] as? NSString) ?? "") as String
            entity.tastingAt = (newData["tasting_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.detail = ((newData["detail"] as? NSString) ?? "") as String
            entity.createdAt = (newData["created_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            entity.updatedAt = (newData["updated_at"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
            
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
