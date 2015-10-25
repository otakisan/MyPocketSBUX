//
//  Seminars.swift
//  MyPocketSBUX
//
//  Created by Takashi Ikeda on 2015/05/14.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit

class Seminars: DbContextBase {
    static var contextInstance : Seminars = Seminars()
    
    class func instance() -> Seminars{
        return contextInstance
    }
    
    override func entityName() -> String {
        return "Seminar"
    }
    
    override func childRelations() -> [(foreignKeyName:String, entityPropertyName:String, destinationEntityName:String, destinationKeyName:String)] {
        return [(foreignKeyName: "storeId", entityPropertyName:"store", destinationEntityName: "store", destinationKeyName: "storeId")]
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {

        for json in jsonObject {
            if let newData = json as? NSDictionary {
                let entity : Seminar = Seminars.instance().createEntity()
                entity.id = (newData["id"] as? NSNumber) ?? 0
                entity.edition = ((newData["edition"] as? NSString) ?? "") as String
                entity.startTime = DateUtility.dateFromSqliteDateTimeString(newData, key: "start_time")
                entity.endTime = DateUtility.dateFromSqliteDateTimeString(newData, key: "end_time")
                entity.dayOfWeek = (newData["day_of_week"] as? NSNumber) ?? 0
                entity.capacity = (newData["capacity"] as? NSNumber) ?? 0
                entity.deadline = (newData["deadline"] as? NSDate) ?? NSDate(timeIntervalSince1970: 0)
                entity.status = ((newData["status"] as? NSString) ?? "") as String
                entity.entryUrl = ((newData["entry_url"] as? NSString) ?? "") as String
                entity.createdAt = DateUtility.dateFromSqliteDateTimeString(newData, key: "created_at")
                entity.updatedAt = DateUtility.dateFromSqliteDateTimeString(newData, key: "updated_at")
                
                // 先に登録して、ManagedObjectContext配下に置かないとリレーション設定の際にエラーになる
                // （不正なコンテキスト、というエラー）
                Seminars.registerEntity(entity)
                if let store : Store = Stores.findByStoreId(Int((newData["store"]?.valueForKey("store_id") as? NSNumber) ?? 0)) {
                    entity.store = store
                }
                
                Seminars.insertEntity(entity)
                
            }
        }
    }
   
}
