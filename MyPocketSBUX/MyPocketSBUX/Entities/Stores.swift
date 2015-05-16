//
//  Stores.swift
//  MyPocketSBUX
//
//  Created by takashi on 2015/04/04.
//  Copyright (c) 2015年 Takashi Ikeda. All rights reserved.
//

import UIKit
import CoreData

class Stores: DbContextBase {
    
    static var contextInstance : Stores = Stores()
    
    class func instance() -> Stores{
        return contextInstance
    }

    override func entityName() -> String {
        return "Store"
    }
    
    class func findByStoreId(storeId : Int) -> Store? {
        
        return (findByFetchRequestTemplate(
            "findStoreByStoreIdFetchRequest",
            variables: ["storeId":storeId],
            sortDescriptors: [],
            limit: 0) as! [Store]).first
    }
    
    override func insertEntityFromJsonObject(jsonObject : NSArray) {
        for json in jsonObject {
            if let newData = json as? NSDictionary {
                var entity : Store = Stores.instance().createEntity()
                entity.id = (newData["id"] as? NSNumber) ?? 0
                entity.storeId = (newData["store_id"] as? NSNumber) ?? 0
                entity.name = ((newData["name"] as? NSString) ?? "") as String
                entity.address = ((newData["address"] as? NSString) ?? "") as String
                entity.phoneNumber = ((newData["phone_number"] as? NSString) ?? "") as String
                entity.holiday = ((newData["holiday"] as? NSString) ?? "") as String
                entity.access = ((newData["access"] as? NSString) ?? "") as String
                entity.openingTimeWeekday = DateUtility.dateFromSqliteDateTimeString(newData, key: "opening_time_weekday")
                entity.closingTimeWeekday = DateUtility.dateFromSqliteDateTimeString(newData, key: "closing_time_weekday")
                entity.openingTimeSaturday = DateUtility.dateFromSqliteDateTimeString(newData, key: "opening_time_saturday")
                entity.closingTimeSaturday = DateUtility.dateFromSqliteDateTimeString(newData, key: "closing_time_saturday")
                entity.openingTimeHoliday = DateUtility.dateFromSqliteDateTimeString(newData, key: "opening_time_holiday")
                entity.closingTimeHoliday = DateUtility.dateFromSqliteDateTimeString(newData, key: "closing_time_holiday")
                entity.latitude = (newData["latitude"] as? NSNumber) ?? 0
                entity.longitude = (newData["longitude"] as? NSNumber) ?? 0
                entity.notes = ((newData["notes"] as? NSString) ?? "") as String
                entity.prefId = (newData["pref_id"] as? NSNumber) ?? 0
                entity.createdAt = DateUtility.dateFromSqliteDateTimeString(newData, key: "created_at")
                entity.updatedAt = DateUtility.dateFromSqliteDateTimeString(newData, key: "updated_at")
                
                Stores.insertEntity(entity)
            }
        }
    }
}
